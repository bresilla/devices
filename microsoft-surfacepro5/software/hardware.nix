{ lib, config, pkgs, ... }:
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  # Built once on tron and published to /kernels; replaces nixos-hardware's kernel.
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor (import ../kernel).kernel);
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
