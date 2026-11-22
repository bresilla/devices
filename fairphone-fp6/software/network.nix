# NetworkManager owns the internet connection; networkd only the USB gadget's usb0.
{ lib, ... }:
{
  imports = [ ../../qualcomm-downstream/software/network.nix ];
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.usePredictableInterfaceNames = false;
  networking.nftables.enable = true;
  # A computer on USB shares its connection: it ranks after Wi-Fi (600) and
  # before mobile data (700). Link-local IPv6 keeps SSH working without it.
  systemd.network.networks."10-fp6-usb" = {
    matchConfig.Name = "usb0";
    networkConfig.DHCP = "ipv4";
    dhcpV4Config.RouteMetric = 650;
    linkConfig.RequiredForOnline = "no";
  };
  networking.networkmanager.unmanaged = [ "interface-name:usb0" ];
}
