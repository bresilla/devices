{ runCommand }:

# Only the Odin 3's share of Armada's firmware; linux-firmware supplies the rest.
runCommand "odin3-firmware" { } ''
  mkdir -p "$out/lib/firmware"
  cp -r --no-preserve=mode ${./blobs}/. "$out/lib/firmware/"
''
