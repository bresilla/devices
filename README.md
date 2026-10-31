# Devices

Firmware, kernels and hardware support for any device, whether or not it is one of
mine. Personal machines, disk layouts and accounts live in
[bresilla/nixos](https://github.com/bresilla/nixos).

Each `<manufacturer-product>/` holds what anyone with that hardware would want:

- `firmware/`: what the hardware itself loads, however it is made.
- `kernel/`: the kernel recipe, with its own pinned nixpkgs.
- `software/`: NixOS modules for that hardware.
- `reference/`: what a stock install looked like, kept for reference; nothing builds from it.

## How it reaches a machine

- **Firmware** is built by CI on push and stored in `cache.bresilla.com/firmwares`.
- **Kernels** are cross-compiled on tron with `make kernels` and stored in
  `cache.bresilla.com/kernels`. Run it before pushing a recipe.
- **`device-recipes`** bundles every `kernel/` and `software/`. The updater in
  bresilla/nixos copies it into its flake.

CI commits `pins.json` only after everything is uploaded, and refuses to publish
when a kernel is missing from `/kernels`, so a machine never compiles one.
Neither cache is pruned; old kernels stay until removed by hand.

## Changing a kernel

1. Edit `<device>/kernel/`.
2. Run `make kernels`.
3. On a device that writes its boot partition directly, such as the Fairphone 6,
   test the image with `fastboot boot` first.
4. Push.

## Licences

The firmware under `firmware/` belongs to its vendors. Recipes and modules here are
mine; `FP6-firmware` upstream states no licence.
