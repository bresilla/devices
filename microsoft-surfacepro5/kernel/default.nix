# Keep this evaluation independent of the host's nixpkgs so updates reuse the
# kernel build.bresilla.com publishes, including its NixOS default configuration.
let
  version = "7.3.1";
  nixpkgsSrc = builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "885ba4d038f10c3d17d7a92e8c3cc185b99c9158";
    shallow = true;
  };
  linuxSurface = builtins.fetchGit {
    url = "https://github.com/linux-surface/linux-surface";
    rev = "668a0208b4a713641f7f04a73631008b1f522257";
    shallow = true;
  };
  system = import (nixpkgsSrc + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [
      ({ lib, pkgs, ... }: {
        boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.buildLinux {
          inherit version;
          modDirVersion = version;
          src = pkgs.fetchurl {
            url = "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-${version}.tar.xz";
            hash = "sha256-+llarZNzT4KcljwqkO98NnMiT9f9rntJQG45fN4t4jE=";
          };
          ignoreConfigErrors = true;
        });
        boot.kernelPatches =
          [
            {
              name = "microsoft-surface-config";
              patch = null;
              structuredExtraConfig = with lib.kernel; {
                # Surface Aggregator Module
                SURFACE_AGGREGATOR = module;
                SURFACE_AGGREGATOR_BUS = yes;
                SURFACE_AGGREGATOR_CDEV = module;
                SURFACE_AGGREGATOR_HUB = module;
                SURFACE_AGGREGATOR_REGISTRY = module;
                SURFACE_AGGREGATOR_TABLET_SWITCH = module;
                SURFACE_ACPI_NOTIFY = module;
                SURFACE_DTX = module;
                SURFACE_PLATFORM_PROFILE = module;
                SURFACE_HID = module;
                SURFACE_KBD = module;
                BATTERY_SURFACE = module;
                CHARGER_SURFACE = module;
                SENSORS_SURFACE_TEMP = module;
                SENSORS_SURFACE_FAN = module;
                RTC_DRV_SURFACE = module;
                SURFACE_HOTPLUG = module;

                # Touch and pen; iptsd does the rest.
                HID_IPTS = module;
                HID_ITHC = module;
                INTEL_THC_HID = module;
                INTEL_QUICKSPI = module;

                # Cameras
                VIDEO_DW9719 = module;
                VIDEO_IPU3_IMGU = module;
                VIDEO_IPU3_CIO2 = module;
                IPU_BRIDGE = module;
                INTEL_SKL_INT3472 = module;
                REGULATOR_TPS68470 = module;
                COMMON_CLK_TPS68470 = module;
                LEDS_TPS68470 = module;
                VIDEO_OV5693 = module;
                VIDEO_OV7251 = module;
                VIDEO_OV8865 = module;

                # Sensors and buttons
                APDS9960 = module;
                INPUT_SOC_BUTTON_ARRAY = module;
                SURFACE_3_POWER_OPREGION = module;
                SURFACE_PRO3_BUTTON = module;
                SURFACE_GPE = module;
                SURFACE_BOOK1_DGPU_SWITCH = module;
                HID_SURFACE = module;
              };
            }
          ]
          ++ map (name: {
            name = "ms-surface/${name}";
            patch = "${linuxSurface}/patches/7.3/${name}.patch";
          }) [
            "0001-secureboot"
            "0002-surface3"
            "0003-mwifiex"
            "0004-ath10k"
            "0005-ipts"
            "0006-ithc"
            "0007-surface-sam"
            "0008-surface-sam-over-hid"
            "0009-surface-button"
            "0010-surface-typecover"
            "0011-surface-shutdown"
            "0012-surface-gpe"
            "0013-cameras"
            "0014-amd-gpio"
            "0015-hid-surface"
          ];
      })
    ];
  };
in
{
  inherit (system.config.boot.kernelPackages) kernel;
}
