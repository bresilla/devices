#!/usr/bin/env bash
# Tablet install, run on core with the tablet on USB:
#   lego-flash.sh unlock sn.img   wipes the tablet and unlocks its bootloader
#   lego-flash.sh flash           adds Wi-Fi and a password, then flashes NixOS
set -euo pipefail
images=/var/tmp/lego-result
work=/var/tmp/lego
provision=$(dirname "$(readlink -f "$0")")/provision.sh
tools=(nix shell nixpkgs#android-tools nixpkgs#openssl nixpkgs#zstd -c)

confirm() {
  read -rp "$1 Type yes to go on: " answer
  [[ $answer == yes ]] || { echo "Stopped."; exit 1; }
}
wait_fastboot() {
  echo "Waiting for fastboot; on the tablet hold Volume Down + Power if it isn't there."
  until [[ -n $("${tools[@]}" fastboot devices) ]]; do sleep 2; done
}

case "${1:-}" in
  unlock)
    file=${2:?usage: lego-flash.sh unlock sn.img}
    [[ -f $file ]] || { echo "No such file: $file"; exit 1; }
    confirm "This wipes the tablet."
    "${tools[@]}" adb reboot bootloader || true
    wait_fastboot
    "${tools[@]}" fastboot flash unlock "$file"
    "${tools[@]}" fastboot oem unlock-go
    echo "Unlocked. Let it reboot, then run: lego-flash.sh flash"
    ;;
  flash)
    [[ -f $images/boot.img ]] || { echo "No images in $images"; exit 1; }
    confirm "This replaces Android with NixOS."
    if [[ ! -f $work/userdata.simg ]]; then
      "${tools[@]}" sudo env "PATH=$PATH" bash "$provision" "$images" "$work" "$USER"
    fi
    "${tools[@]}" adb reboot bootloader 2>/dev/null || true
    wait_fastboot
    [[ $("${tools[@]}" fastboot getvar unlocked 2>&1) == *"unlocked: yes"* ]] \
      || { echo "The bootloader is still locked; run the unlock step."; exit 1; }
    "${tools[@]}" fastboot flash boot_a "$work/boot.img"
    "${tools[@]}" fastboot flash super "$work/super.img"
    "${tools[@]}" fastboot -S 700M flash userdata "$work/userdata.simg"
    "${tools[@]}" fastboot reboot
    echo "Flashed. If the screen stays black after the logo, pick NixOS (other panel) at the menu."
    ;;
  *)
    echo "usage: lego-flash.sh unlock sn.img | flash"
    exit 2
    ;;
esac
