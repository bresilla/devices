{ runCommand }:

# Wi-Fi and Bluetooth firmware: RPi-Distro firmware-nonfree and bluez-firmware.
runCommand "raspberrypi-wireless-firmware-2026-03-21" { } ''
  mkdir -p "$out"
  cp -r --no-preserve=mode ${./wireless}/. "$out/"
''
