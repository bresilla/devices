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

build.bresilla.com builds the flake's `checks` on every push to main, as
`.muros.lua` describes, and pins each result in cache.bresilla.com:

- **Firmware** and NVIDIA's drivers go to `cache.bresilla.com/firmwares`.
- **Kernels**, cross-compiled on tron, go to `cache.bresilla.com/kernels`.
- **`device-recipes`** bundles every `kernel/` and `software/`. The updater in
  bresilla/nixos copies it into its flake.

`device-recipes` depends on every kernel, so it is pinned only once they are all
built, and a machine never compiles one. A failed build keeps the previous pin.
Neither cache is pruned; old kernels stay until removed by hand.

## Changing a kernel

1. Edit `<device>/kernel/`.
2. On a device that writes its boot partition directly, such as the Fairphone 6,
   test the image with `fastboot boot` first.
3. Push, and follow the run on build.bresilla.com.

The T480's pinned NixOS kernel enables the ThinkPad driver facilities needed to bypass
coreboot's false master-radio block; the hardware module supplies the switch
parameters. Normal host updates reuse the cached kernel and modules.

## Licences

The firmware under `firmware/` belongs to its vendors. Recipes and modules here are
mine; `FP6-firmware` upstream states no licence.
