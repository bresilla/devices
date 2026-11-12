# The Raspberry Pi 5 vendor kernel from nixos-raspberrypi, on that project's own pinned
# nixpkgs, so updates never rebuild it. It cross-compiles on x86_64 and is published to
# /kernels; the Pi only downloads it.
{
  buildSystem ? "aarch64-linux",
}:

let
  rpi = import ../software/nixos-raspberrypi.nix;
  platform =
    if buildSystem == "aarch64-linux" then
      { system = "aarch64-linux"; }
    else
      {
        localSystem = buildSystem;
        crossSystem = "aarch64-linux";
      };
  pkgs = import rpi.inputs.nixpkgs (platform // {
    # As nixos-raspberrypi assembles its own packages.
    overlays = map (name: rpi.overlays.${name}) [
      "pkgs"
      "bootloader"
      "vendor-kernel"
      "vendor-firmware"
      "kernel-and-firmware"
      "vendor-pkgs"
    ];
  });
in
{
  kernel = pkgs.linux_rpi5;
}
