{ runCommand, xz }:

# The UEFI loader for boot_a and the GRUB it starts, from Armada's TB321FU release
# v20261024.0146e89; neither is built from source there either.
runCommand "tb321fu-loader" { nativeBuildInputs = [ xz ]; } ''
  mkdir -p "$out/boot"
  cp -r --no-preserve=mode ${./loader/EFI} "$out/EFI"
  cp -r --no-preserve=mode ${./loader/grub} "$out/boot/grub"
  xz -dc ${./loader/boot.img.xz} > "$out/boot.img"
''
