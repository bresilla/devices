{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  bresilla.features.system = {
    architecture = "x86_64";
    cpuVendor = "intel";
  };
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "thinkpad_acpi.force_load=1"
  ];
  boot.kernelModules = [ "thinkpad_acpi" ];
  # Built once on tron and published to /kernels, independently of host updates.
  boot.kernelPackages = pkgs.linuxPackagesFor (import ../kernel).kernel;
}
