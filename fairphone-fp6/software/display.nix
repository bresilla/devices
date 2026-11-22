# The panel's display pipeline has no colour block for its mixers: any colour matrix,
# even hyprsunset's neutral one, fails every frame and freezes the screen.
{ lib, pkgs, ... }:
{
  programs.eva.uiScale = 1.8;
  systemd.user.services.eva-hyprsunset.enable = false;
  # eva's night light also starts it by name when switched on; here that does nothing.
  environment.systemPackages = [ (lib.hiPrio (pkgs.writeShellScriptBin "hyprsunset" "exit 0")) ];
}
