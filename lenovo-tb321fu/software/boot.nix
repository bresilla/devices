{ lib, ... }:

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

  systemd.tpm2.enable = false;
  boot.initrd.systemd = {
    enable = true;
    tpm2.enable = false;
  };
}
