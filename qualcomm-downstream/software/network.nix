# Phones and handhelds on Qualcomm's downstream kernels. Their ath Wi-Fi joins (hidden
# networks too) through wpa_supplicant, not iwd; the kernels lack the nftables FIB
# matcher the reverse-path filter uses; NetworkManager owns the network.
{ lib, ... }:
{
  networking.networkmanager.wifi.backend = "wpa_supplicant";
  networking.firewall.checkReversePath = lib.mkForce false;
  systemd.network.wait-online.enable = false;
}
