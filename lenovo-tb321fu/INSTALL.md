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
6. First boot: Lenovo logo, the systemd-boot menu, NixOS. If the screen stays black after
   the logo, restart and pick **NixOS (csot)**.

## What happened on 2026-11-05

- The unit: TB321FU_EEA, 12 GB + 256 GB, serial `HA2AJN4H`, ZUI 17.5.10.272 (ROW),
  Android 16, bootloader locked. `ro.vendor.display.paneltype` is `1`; which panel that
  means is unknown, so the first boot decides BOE or CSOT.
- Developer options: tap **ZUI version** 7 times, not Build number (that one is greyed out).
- Android was not updated, so the update could not take OEM unlocking away. OEM
  unlocking is on.
- Fastboot only appears on one of the tablet's two USB-C ports: the one where Android
  connects at USB 3 (SuperSpeed). On the other port the bootloader shows its menu but
  never enumerates. core's USB-C ports saw nothing in either port; nova's USB-A did.
- `fastboot flash unlock` with the NekoYuzu-generated `sn.img` hung at "Sending" twice,
  the second time ending in "press any key to shutdown". Nothing was written; the
  tablet still boots Android. Two suspects, not yet told apart: that bootloader
  rejects the generic file, or fastboot's bulk transfer stalls over USB 3 (nova logged
  `error -71`). Other fastboot commands, such as `oem device-info`, work.
- Lenovo's own file: apply at https://www.zui.com/iunlock (log in with a Lenovo
  account, tab **Lenovo平板**, serial, e-mail, the number shown as 验证码, tick the
  risk box, submit). The file then appears at
  `http://cdn.zui.lenovomm.com/developer/tabletboot/HA2AJN4H/sn.img`, about 30
  minutes later; no e-mail is needed. The first try got "今日解锁数量已达限额" (daily
  quota reached). The quota resets at midnight China time, 17:00 in the Netherlands,
  so submit just after that. One account may unlock three devices a year.

## What happened on 2026-11-06

- The zui.com application went through just after 17:00; the CDN file appeared about
  5 minutes later. It is a 5386-byte `ANDROID!` image, unlike the generic one.
- The hangs were Linux USB autosuspend: the host suspends the idle fastboot device
  after 2 seconds and this bootloader never wakes from it. Any command sent right after
  the tablet enumerates works; later ones hang at "Sending" or drop off the bus. Fix on
  the flashing host, until its next reboot:
  `echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend`, then re-enter
  fastboot. With that, every command works at any time.
- At USB 2 speed (a hub, or USB 3 disabled on the port) the bootloader does not
  enumerate at all (`error -71`). It needs the direct USB 3 link.
- `flash unlock` keeps the file only until the bootloader restarts; `oem unlock-go` in
  a later session answers "unknown command". The unlock went through anyway: the
  fastboot screen shows `DEVICE STATE - unlocked` and `getvar unlocked` says yes.
- Provisioning needs about 52 GB free: the unpacked userdata is 26 GB and its sparse
  image is 26 GB too. nova's `/var/tmp` (32 GB) ran out, so the images were provisioned
  on core and the sparse files copied to nova's `/nix`.
- Flashed `boot_a`, `super`, `userdata` (83 seconds), rebooted: NixOS booted on the
  BOE panel and joined Wi-Fi. systemd-boot 260.5, started from GRUB as a test, booted
  NixOS with its `devicetree` line as well.

## After it boots

- Clone `~/.dot` and write `/etc/nixos`.
- Fix the rotation in `software/display.nix` if it is wrong; it is copied from the Odin 3.
- Test the pen at 120 Hz with `libinput debug-events --verbose`: tilt must move. If it
  stays 0, inspect the touch firmware's pen report. The driver handles both pen formats.
- The Amazon return window ends 31 January 2027.

## If it goes wrong

Fastboot stays reachable with Volume Down + Power: reflash, or restore Lenovo's stock
firmware for the TB321FU to get Android back. The bootloader stays unlocked.
