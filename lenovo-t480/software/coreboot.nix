# For a T480 running coreboot, which reports a disabled master radio switch: keep the
# ThinkPad hotkeys and battery controls while bypassing the false hard block, and lift
# the soft block loading thinkpad_acpi can leave on Wi-Fi.
{ pkgs, ... }:
{
  boot.extraModprobeConfig = ''
    options thinkpad_acpi dbg_wlswemul=1 wlsw_state=1
  '';
  systemd.services.thinkpad-wifi-unblock = {
    description = "Unblock Wi-Fi after loading the ThinkPad driver";
    wantedBy = [ "multi-user.target" ];
    requires = [ "systemd-modules-load.service" ];
    after = [ "systemd-modules-load.service" "systemd-rfkill.service" ];
    before = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock wifi";
    };
  };
}
