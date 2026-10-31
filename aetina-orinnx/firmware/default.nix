{ runCommand }:

# NVIDIA's nvidia-l4t-firmware deb, JetPack 7 (L4T 39.2.1), unpacked.
runCommand "nvidia-l4t-firmware-39.2.1-20260806224157" { } ''
  mkdir -p "$out"
  cp -r --no-preserve=mode ${./blobs}/. "$out/"
''
