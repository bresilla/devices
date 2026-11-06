{ runCommand, xz }:

# DuoWoA's UEFI for boot_a and Armada's QCOMRAMP.EFI for the FAT, from Armada's
# TB321FU release v20261024.0146e89; neither is built from source there either.
runCommand "tb321fu-loader" { nativeBuildInputs = [ xz ]; } ''
  mkdir -p "$out/EFI/BOOT"
  cp ${./loader/EFI/BOOT/QCOMRAMP.EFI} "$out/EFI/BOOT/QCOMRAMP.EFI"
  xz -dc ${./loader/boot.img.xz} > "$out/boot.img"
''
