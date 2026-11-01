{
  config,
  lib,
  pkgs,
  firmwares,
  ...
}:

let
  cfg = config.bresilla.tb321fu;
  # The kernel itself comes from /kernels.
  tb321fu = import ../kernel { buildSystem = cfg.kernelBuildSystem; };
in
{
  options.bresilla.tb321fu.kernelBuildSystem = lib.mkOption {
    type = lib.types.enum [
      "aarch64-linux"
      "x86_64-linux"
    ];
    default = "x86_64-linux";
    description = "Where the kernel compiles; x86_64 matches the store path in /kernels.";
  };

  config = {
    boot.kernelPackages = pkgs.linuxPackagesFor tb321fu.kernel;
    hardware.firmware = [ (lib.hiPrio firmwares.tb321fu-firmware) ];
    hardware.deviceTree.enable = true;

    boot.initrd = {
      includeDefaultModules = false;
      availableKernelModules = lib.filter (name: name != "") (
        lib.splitString "\n" (builtins.readFile ../kernel/initrd-modules)
      );
      extraFirmwarePaths = [
        "qcom/sm8650/lenovo/tb321fu/adsp.mdt"
        "qcom/sm8650/lenovo/tb321fu/adsp_dtb.mdt"
        "qcom/sm8650/lenovo/tb321fu/cdsp.mdt"
        "qcom/sm8650/lenovo/tb321fu/cdsp_dtb.mdt"
      ];
    };

    # Armada's arguments, less what belongs to its btrfs root.
    boot.kernelParams = [
      "console=tty0"
      "efi=novamap"
      "fbcon=map:0"
      "allow_mismatched_32bit_el0"
      "fw_devlink.strict=1"
      "pcie_ports=compat"
      "psi=1"
      "cgroup_disable=pressure"
      "cgroup.memory=nokmem,nosocket"
      "cpufreq.default_governor=schedutil"
      "swiotlb=8192"
      "mem_sleep_default=s2idle"
    ];
    boot.consoleLogLevel = 7;
  };
}
