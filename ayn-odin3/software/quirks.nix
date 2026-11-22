# What this kernel lacks or the board leaves out.
{ lib, ... }:
{
  imports = [ ../../qualcomm-downstream/software/network.nix ];
  networking.networkmanager.logLevel = "INFO";
  # The iio module wants hid-sensor-hub in the initrd, which this kernel lacks.
  hardware.sensor.iio.enable = lib.mkForce false;
}
