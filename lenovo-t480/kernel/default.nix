# Keep this evaluation independent of the host's nixpkgs so updates reuse the
# kernel uploaded by `make kernels`, including its NixOS default configuration.
let
  nixpkgsSrc = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "1f607aa79b6356ed45d3cd3c8079c196e79efa2c";
    shallow = true;
  };
  system = import (nixpkgsSrc + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [
      ({ lib, ... }: {
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
