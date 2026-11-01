{ runCommand }:

# The tablet's own share of Armada's firmware, from firmware-lenovo-tb321fu 2026.10.15.
runCommand "tb321fu-firmware" { } ''
  mkdir -p "$out/lib/firmware" "$out/share/qcom"
  cp -r --no-preserve=mode ${./blobs}/. "$out/lib/firmware/"
  cp -r --no-preserve=mode ${./sensors}/. "$out/share/qcom/"
''
