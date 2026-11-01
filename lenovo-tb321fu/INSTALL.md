# Installing NixOS on the Legion Tab Gen 3

Written 2026-11-01, before the tablet arrived. Nothing here has run on real hardware yet.

## What is ready

- Kernel in `/kernels`, firmware and loader in `/firmwares`, recipes pinned.
- Device `lenovo-tb321fu` (hostname `lego`) in bresilla/nixos.
- Images on core in `/var/tmp/lego-result`: `boot.img`, `super.img`, `userdata.img.zst`.
  If they are gone or the configuration changed, run `software/scripts/build-images.sh` on
  lama, then `nix copy --no-check-sigs --from ssh-ng://lama.netbird <result path>` on core
  and point `/var/tmp/lego-result` at it.
- Working on paper: display, touch, pen, GPU, Wi-Fi, Bluetooth, speakers, USB networking.
- Not ported: cameras, auto-rotate, light sensor, haptics.

## When it arrives

1. Enable Developer options and USB debugging, and plug it into core. Read the model,
   firmware and lock state first: it must be a TB321FU.
2. Test the Lenovo Tab Pen Plus (AP500U) on Android: pressure, and tilt in a drawing app
   with tilt-sensitive brushes. Unlocking wipes Android, so this is the only chance.
3. Update Android, as Armada does (it tested ZUI 17.5.10.319, global build).
4. Turn on **OEM unlocking**. Get `sn.img` for the serial number from lenovobl.neko.ink.
5. Unlock, which wipes the tablet, then flash. Run from `~/.devices/lenovo-tb321fu`:

   ```sh
   bash software/scripts/flash.sh unlock sn.img
   bash software/scripts/flash.sh flash
   ```

   `flash` adds core's Wi-Fi and a password, and stops if the bootloader is locked.
6. First boot: Lenovo logo, a 3-second GRUB menu, NixOS. If the screen stays black after
   the logo, restart and pick **NixOS (other panel)**. On a CSOT unit, keep that with
   `sudo touch /boot/panel-csot` and a switch.

## After it boots

- Clone `~/.dot` and write `/etc/nixos`.
- Fix the rotation in `software/display.nix` if it is wrong; it is copied from the Odin 3.
- Test the pen at 120 Hz with `libinput debug-events --verbose`: tilt must move. If it
  stays 0, inspect the touch firmware's pen report. The driver handles both pen formats.
- The Amazon return window ends 31 January 2027.

## If it goes wrong

Fastboot stays reachable with Volume Down + Power: reflash, or restore Lenovo's stock
firmware for the TB321FU to get Android back. The bootloader stays unlocked.
