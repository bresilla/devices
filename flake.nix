{
  description = "Firmware and kernels for any device, served from cache.bresilla.com";

  # <device>/firmware/: what the hardware itself loads, however it is made.
  # <device>/kernel/: a kernel's recipe.
  # <device>/software/: hardware modules anyone with that device would want.
  # Machines read both through the device-recipes pin, which CI publishes only once
  # every kernel below is in /kernels.

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };
    in
    {
      packages.aarch64-linux = {
        fp6-firmware = pkgs.callPackage ./fairphone-fp6/firmware { };
        fp6-audio-firmware = pkgs.callPackage ./fairphone-fp6/firmware/audio.nix { };
        fp6-sensor-firmware = pkgs.callPackage ./fairphone-fp6/firmware/sensors.nix { };
        fp6-fingerprint-firmware = pkgs.callPackage ./fairphone-fp6/firmware/fingerprint { };
        odin3-firmware = pkgs.callPackage ./ayn-odin3/firmware { };
        nvidia-gsp-firmware = pkgs.callPackage ./lenovo-pgx/firmware { };
        nvidia-l4t-firmware = pkgs.callPackage ./aetina-orinnx/firmware { };
        r8168-firmware = pkgs.callPackage ./aetina-orinnx/firmware/r8168.nix { };
        raspberrypi-firmware = pkgs.callPackage ./raspberrypi-pi5/firmware { };
        raspberrypi-wireless-firmware = pkgs.callPackage ./raspberrypi-pi5/firmware/wireless.nix { };
        device-recipes = pkgs.runCommand "device-recipes" { } ''
          mkdir -p "$out/fairphone-fp6" "$out/ayn-odin3" "$out/lenovo-pgx" "$out/lenovo-t480"
          mkdir -p "$out/aetina-orinnx/firmware"
          cp -r ${./aetina-orinnx/firmware/r36} "$out/aetina-orinnx/firmware/r36"
          cp -r ${./aetina-orinnx/kernel} "$out/aetina-orinnx/kernel"
          cp -r ${./fairphone-fp6/kernel} "$out/fairphone-fp6/kernel"
          cp -r ${./fairphone-fp6/software} "$out/fairphone-fp6/software"
          cp -r ${./ayn-odin3/kernel} "$out/ayn-odin3/kernel"
          cp -r ${./ayn-odin3/software} "$out/ayn-odin3/software"
          cp -r ${./lenovo-pgx/kernel} "$out/lenovo-pgx/kernel"
          cp -r ${./lenovo-t480/software} "$out/lenovo-t480/software"
        '';
        # Machines not yet updated still read this name.
        kernel-recipes = pkgs.runCommand "kernel-recipes" { } ''
          mkdir -p "$out/fairphone-fp6" "$out/ayn-odin3" "$out/lenovo-pgx"
          cp -r ${./fairphone-fp6/kernel} "$out/fairphone-fp6/kernel"
          cp -r ${./ayn-odin3/kernel} "$out/ayn-odin3/kernel"
          cp -r ${./lenovo-pgx/kernel} "$out/lenovo-pgx/kernel"
        '';
      };

      # Every output a machine downloads from /kernels; always cross-built on tron.
      kernels =
        let
          buildSystem = "x86_64-linux";
          fp6 = import ./fairphone-fp6/kernel { inherit buildSystem; };
          odin3 = import ./ayn-odin3/kernel { inherit buildSystem; };
          spark = import ./lenovo-pgx/kernel {
            inherit buildSystem;
            dgxSpark = import ./lenovo-pgx/kernel/dgx-spark.nix;
          };
        in
        {
          fp6 = fp6.kernel;
          odin3 = odin3.kernel;
          spark = spark.kernel;
        };

      # What else a kernel's machine downloads from /kernels: NVIDIA's driver for it.
      kernelExtras =
        let
          spark = import ./lenovo-pgx/kernel {
            buildSystem = "x86_64-linux";
            dgxSpark = import ./lenovo-pgx/kernel/dgx-spark.nix;
          };
        in
        [
          spark.kernel.configfile
          spark.nvidiaOpen
          spark.driver
          spark.nvidiaTools
          spark.driver.persistenced
        ];
    };
}
