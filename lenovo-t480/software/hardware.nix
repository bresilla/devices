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
  boot.resumeDevice = "/dev/pool/swap";
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "thinkpad_acpi.force_load=1"
  ];
  boot.kernelModules = [ "thinkpad_acpi" ];
  # Built once on tron and published to /kernels, independently of host updates.
  boot.kernelPackages = pkgs.linuxPackagesFor (import ../kernel).kernel;
  # Coreboot reports a disabled master radio switch on this hardware. Preserve
  # ThinkPad hotkeys/battery controls while bypassing the false hard block.
  boot.extraModprobeConfig = ''
    options thinkpad_acpi dbg_wlswemul=1 wlsw_state=1
  '';

  # With coreboot, loading thinkpad_acpi can soft-block Wi-Fi.
  systemd.services.thinkpad-wifi-unblock = {
    description = "Unblock Wi-Fi after loading the ThinkPad driver";
    wantedBy = [ "multi-user.target" ];
    requires = [ "systemd-modules-load.service" ];
    after = [ "systemd-modules-load.service" "systemd-rfkill.service" ];
    before = [ "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock wifi";
    };
  };
}
