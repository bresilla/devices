{
  description = "Firmware and kernels for any device, served from cache.bresilla.com";

  # <device>/firmware/: what the hardware itself loads, however it is made.
  # <device>/kernel/: a kernel's recipe. Machines read it through the kernel-recipes
  # pin, which CI publishes only once every kernel below is in /kernels.

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
    };
}
