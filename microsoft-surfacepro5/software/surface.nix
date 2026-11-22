# The Surface kernel and drivers from nixos-hardware, and the pen over the touchscreen:
# every touch is ignored while the pen is in proximity, hover included.
{ ... }:
{
  imports = [ "${import ./nixos-hardware.nix}/microsoft/surface/surface-pro-intel" ];
  bresilla.programs.iptsd.enable = true;
  services.iptsd.config.Touchscreen = {
    DisableOnStylus = true;
    DisableOnStylusDelay = 1000; # Milliseconds after the pen leaves proximity.
  };
}
