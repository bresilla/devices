# Keep this evaluation independent of the host's nixpkgs so updates reuse the
# kernel build.bresilla.com publishes, including its NixOS default configuration.
let
  nixpkgsSrc = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "885ba4d038f10c3d17d7a92e8c3cc185b99c9158";
    shallow = true;
  };
  system = import (nixpkgsSrc + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [
      ({ lib, pkgs, ... }: {
        boot.kernelPackages = pkgs.linuxPackages_7_3;
        boot.kernelPatches = [
          {
            name = "thinkpad-coreboot-radio-workaround";
            patch = null;
            structuredExtraConfig.THINKPAD_ACPI_DEBUGFACILITIES = lib.kernel.yes;
          }
        ];
      })
    ];
  };
in
{
  inherit (system.config.boot.kernelPackages) kernel;
}
