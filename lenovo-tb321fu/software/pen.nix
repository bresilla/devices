{ pkgs, ... }:
let
  # The AP500U on the panel's Novatek digitizer, as an on-screen tablet. The kernel
  # reports no axis resolution; these give libinput one-to-one coordinates.
  libwacom = pkgs.writeTextDir "share/libwacom/lenovo-tb321fu-pen.tablet" ''
    [Device]
    Name=Lenovo Legion Tab Pen Plus
    ModelName=AP500U
    DeviceMatch=spi|1c|0
    Class=ISDV4
    Width=5
    Height=7
    IntegratedIn=Display;System

    [Features]
    Stylus=true
    Touch=false
    Buttons=2
  '';
in
{
  services.udev.extraHwdb = ''
    evdev:name:NVTCapacitivePen:*
     EVDEV_ABS_00=::136
     EVDEV_ABS_01=::135
  '';
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="NVTCapacitivePen", ENV{ID_INPUT_TABLET_INTEGRATED}="1", ENV{WL_OUTPUT}="DSI-1"
  '';
  environment.systemPackages = [ libwacom ];
  environment.pathsToLink = [ "/share/libwacom" ];
}
