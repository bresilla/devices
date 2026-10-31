{
  description = "Firmware for any device, served from cache.bresilla.com/firmwares";

  # <device>/firmware/: what the hardware itself loads, however it is made.

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
      };
    };
}
