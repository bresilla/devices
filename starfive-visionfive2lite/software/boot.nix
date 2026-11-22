# Boots from its microSD card: U-Boot lives in the SPI flash (vf2lite-flash-uboot writes
# it) and boots extlinux from the card, so the image has no firmware partition.
{ config, lib, modulesPath, ... }:
{
  imports = [ "${modulesPath}/installer/sd-card/sd-image.nix" ];
  sdImage = {
    imageBaseName = config.networking.hostName;
    compressImage = false;
    populateFirmwareCommands = "";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
  # Ethernet is all the board has on mainline, so networkd rather than NetworkManager.
  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;
  networking.useDHCP = lib.mkForce true;
  # An SD card has no SMART data, so smartd only fails.
  services.smartd.enable = lib.mkForce false;
}
