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
        tb321fu-firmware = pkgs.callPackage ./lenovo-tb321fu/firmware { };
        tb321fu-loader = pkgs.callPackage ./lenovo-tb321fu/firmware/loader.nix { };
        nvidia-gsp-firmware = pkgs.callPackage ./lenovo-pgx/firmware { };
        nvidia-l4t-firmware = pkgs.callPackage ./aetina-orinnx/firmware { };
        r8168-firmware = pkgs.callPackage ./aetina-orinnx/firmware/r8168.nix { };
        raspberrypi-firmware = pkgs.callPackage ./raspberrypi-pi5/firmware { };
        raspberrypi-wireless-firmware = pkgs.callPackage ./raspberrypi-pi5/firmware/wireless.nix { };
        # Every device's kernel/ and software/; firmware stays out, as its blobs are large.
        device-recipes =
          let
            inherit (pkgs) lib;
            devices = builtins.attrNames (lib.filterAttrs (name: type: type == "directory" && !lib.hasPrefix "." name) (builtins.readDir ./.));
            copy = device: part:
              lib.optionalString (builtins.pathExists (./. + "/${device}/${part}")) ''
                mkdir -p "$out/${device}"
                cp -r ${./. + "/${device}/${part}"} "$out/${device}/${part}"
              '';
          in
          pkgs.runCommand "device-recipes" { } ''
            ${lib.concatMapStrings (device: copy device "kernel" + copy device "software") devices}
            mkdir -p "$out/aetina-orinnx/firmware"
            cp -r ${./aetina-orinnx/firmware/r36} "$out/aetina-orinnx/firmware/r36"
          '';
      };

      # Every output a machine downloads from /kernels; always cross-built on tron.
      kernels =
        let
          buildSystem = "x86_64-linux";
          fp6 = import ./fairphone-fp6/kernel { inherit buildSystem; };
          odin3 = import ./ayn-odin3/kernel { inherit buildSystem; };
          tb321fu = import ./lenovo-tb321fu/kernel { inherit buildSystem; };
          spark = import ./lenovo-pgx/kernel {
            inherit buildSystem;
            dgxSpark = import ./lenovo-pgx/kernel/dgx-spark.nix;
          };
        in
        {
          fp6 = fp6.kernel;
          odin3 = odin3.kernel;
          tb321fu = tb321fu.kernel;
          spark = spark.kernel;
        };

      # What else a kernel's machine downloads from /kernels.
      kernelExtras =
        let
          spark = import ./lenovo-pgx/kernel {
            buildSystem = "x86_64-linux";
            dgxSpark = import ./lenovo-pgx/kernel/dgx-spark.nix;
          };
        in
        [ spark.kernel.configfile ];

      # NVIDIA's driver for those kernels. /kernels holds kernels only, so these live in
      # /firmwares; unpinned and kept there forever, like the rest of that cache.
      nvidia =
        let
          spark = import ./lenovo-pgx/kernel {
            buildSystem = "x86_64-linux";
            dgxSpark = import ./lenovo-pgx/kernel/dgx-spark.nix;
          };
        in
        [
          spark.nvidiaOpen
          spark.driver
          spark.nvidiaTools
          spark.driver.persistenced
        ];
    };
}
