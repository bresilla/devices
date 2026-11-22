# What this kernel lacks or the tablet leaves out.
{ lib, ... }:
{
  imports = [ ../../qualcomm-downstream/software/network.nix ];
  networking.networkmanager.logLevel = "INFO";
  # A phone without the phone parts: no modem, no fingerprint reader.
  bresilla.features.network.cellular.enable = false;
  bresilla.features.system.fingerprint.enable = false;
  # The sensor hub is not ported, and the iio module wants hid-sensor-hub in the initrd.
  hardware.sensor.iio.enable = lib.mkForce false;
}
