{ lib, pkgs, ... }:

{
  # DuoWoA's UEFI in boot_a starts systemd-boot from the FAT at the start of super.
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  # /boot is a loop-mounted FAT, which bootctl refuses as an ESP without this.
  systemd.globalEnvironment.SYSTEMD_RELAX_ESP_CHECKS = "1";

  # BOE panel by default; the CSOT panel needs its own device tree.
  hardware.deviceTree.name = "qcom/sm8650-lenovo-tb321fu.dtb";
  specialisation.csot.configuration.hardware.deviceTree.name =
    lib.mkForce "qcom/sm8650-lenovo-tb321fu-csot.dtb";

  # Lenovo's ABL stops booting slot A after 7 boots not marked successful and
  # falls into recovery, before systemd-boot ever shows. Mark every good boot,
  # as Armada does (GPT attribute 54 on boot_a). INSTALL.md has the way back.
  systemd.services.tb321fu-mark-boot-successful = {
    description = "Mark A/B slot A successful for Lenovo's bootloader";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    path = [ pkgs.gptfdisk pkgs.util-linux pkgs.coreutils ];
    serviceConfig.Type = "oneshot";
    script = ''
      part=$(readlink -f /dev/disk/by-partlabel/boot_a)
      disk=$(lsblk -no PKNAME "$part")
      sgdisk -A "$(cat /sys/class/block/$(basename "$part")/partition):set:54" "/dev/$disk"
    '';
  };

  systemd.tpm2.enable = false;
  boot.initrd.systemd = {
    enable = true;
    tpm2.enable = false;
  };
}
