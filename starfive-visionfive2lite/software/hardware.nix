# StarFive VisionFive 2 Lite (JH7110S), microSD variant, on mainline Linux. HDMI, GPU,
# Wi-Fi and Bluetooth have no mainline support yet; Ethernet, NVMe, USB and SD do.
{ lib, pkgs, ... }:

let
  # Cross-built on tron, as /kernels and /firmwares hold them.
  vf2lite = import ../kernel { buildSystem = "x86_64-linux"; };
  firmware = import ../firmware { buildSystem = "x86_64-linux"; };
  # Writes U-Boot to the SPI flash from Linux; the recovery button covers a bad write.
  flash = pkgs.writeShellApplication {
    name = "vf2lite-flash-uboot";
    runtimeInputs = [ pkgs.mtdutils ];
    text = ''
      flashcp -v ${firmware}/share/vf2lite/u-boot-spl.bin.normal.out /dev/mtd0
      flashcp -v ${firmware}/share/vf2lite/u-boot.itb /dev/mtd2
    '';
  };
in
{
  nixpkgs.hostPlatform = lib.mkDefault "riscv64-linux";
  boot.kernelPackages = pkgs.linuxPackagesFor vf2lite.kernel;
  # U-Boot picks the same tree from the EEPROM; naming it keeps extlinux explicit.
  hardware.deviceTree.name = "starfive/jh7110-starfive-visionfive-2-lite.dtb";
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200" "earlycon" ];
  boot.initrd.availableKernelModules = [
    "dw_mmc_starfive"
    "clk-starfive-jh7110-aon"
    "clk-starfive-jh7110-stg"
    "phy-jh7110-pcie"
    "pcie-starfive"
    "nvme"
  ];
  environment.systemPackages = [ flash ];
}
