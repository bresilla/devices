{ lib, pkgs, firmwares, bresilla, ... }:
let
  dgxSpark = import ../kernel/dgx-spark.nix;
  # Always cross-compiled on an x86_64 builder; the machine downloads it from /kernels.
  spark = import ../kernel {
    inherit dgxSpark;
    buildSystem = "x86_64-linux";
  };
  # Pinned with the kernel, so system updates never move the driver.
  inherit (spark) driver;
in
{
  imports = [
    "${dgxSpark}/modules/dgx-spark.nix"
  ];

  hardware.dgx-spark.enable = true;
  # As DGX OS boots: CUDA's unified memory uses ATS, which needs the SMMU translating, and
  # zeroing every allocation slows large model loads.
  boot.kernelParams = [ "iommu.passthrough=0" "init_on_alloc=0" ];
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor spark.kernel);
  hardware.nvidia.package = lib.mkForce (
    driver
    // {
      bin = spark.nvidiaTools;
      open = spark.nvidiaOpen;
      # The open module loads only the firmware of this exact driver version.
      firmware = assert firmwares.nvidia-gsp-firmware.name == "nvidia-gsp-firmware-${driver.version}";
        firmwares.nvidia-gsp-firmware;
    }
  );

  # CUDA lives in development shells; system-wide it would rebuild every CUDA-capable
  # package, none of which the binary caches carry.
  nixpkgs.config.cudaSupport = false;
  # The DGX Spark module takes nvtop from here; this one is built by packages/.
  nixpkgs.overlays = [
    (final: prev: {
      nvtopPackages = prev.nvtopPackages // { nvidia = bresilla.nvtop; };
    })
  ];
  # Headless: no GTK settings app.
  hardware.nvidia.nvidiaSettings = lib.mkForce false;
  # Ollama with CUDA, from its own release; the GB10 shares its memory with the CPU, so
  # Ollama counts it as integrated and skips it unless told otherwise.
  services.ollama.package = lib.mkForce (bresilla.ollama-cuda-bin // { meta.mainProgram = "ollama"; });
  services.ollama.environmentVariables.OLLAMA_IGPU_ENABLE = "1";

  assertions = [
    {
      # nixpkgs.config merges without priorities; fail rather than rebuild everything.
      assertion = !pkgs.config.cudaSupport;
      message = "DGX Spark: nixpkgs.config.cudaSupport must stay off system-wide.";
    }
    {
      assertion = lib.hasPrefix driver.version spark.nvidiaOpen.version;
      message = "DGX Spark: the NVIDIA libraries and kernel module versions differ.";
    }
  ];
}
