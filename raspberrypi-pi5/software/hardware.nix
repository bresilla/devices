{ lib, firmwares, ... }:
let
  nixos-raspberrypi = import ./nixos-raspberrypi.nix;
in
{
  # Firmware comes from ../firmware; nixos-raspberrypi still supplies the kernel.
  boot.loader.raspberry-pi.firmwarePackage = firmwares.raspberrypi-firmware;
  nixpkgs.overlays = [
    (_: _: { raspberrypiWirelessFirmware = firmwares.raspberrypi-wireless-firmware; })
  ];

  # Vendor kernel from nixos-raspberrypi, prebuilt on its Cachix.
  imports = with nixos-raspberrypi.nixosModules; [
    nixpkgs-rpi
    nixos-raspberrypi.lib.inject-overlays
    trusted-nix-caches
    raspberry-pi-5.base
    raspberry-pi-5.display-vc4
    raspberry-pi-5.bluetooth
  ];
  # Its modules expect themselves as an argument.
  _module.args.nixos-raspberrypi = nixos-raspberrypi;
  # The SD-image base profile adds ZFS, which would mean compiling it for this kernel.
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
