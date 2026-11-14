# What the board boots before Linux, written to its SPI flash: U-Boot's SPL, and
# OpenSBI with U-Boot proper as one FIT image. Mainline U-Boot knows the Lite from
# its EEPROM since 2026.07, so its device tree is picked without help.
{
  buildSystem ? "riscv64-linux",
}:

let
  inherit (import ../kernel { inherit buildSystem; }) pkgs;
  uboot = pkgs.ubootVisionFive2;
in
pkgs.buildPackages.runCommand "vf2lite-firmware" { } ''
  mkdir -p $out/share/vf2lite
  cp ${uboot}/u-boot-spl.bin.normal.out ${uboot}/u-boot.itb $out/share/vf2lite/
''
