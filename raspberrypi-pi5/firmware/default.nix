{ runCommand }:

# The boot partition's files, from raspberrypi/firmware bead686 (matches kernel 6.18.52).
runCommand "raspberrypi-firmware-20260915" { } ''
  mkdir -p "$out"
  cp -r --no-preserve=mode ${./blobs}/. "$out/"
''
