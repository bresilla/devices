{ pkgs, ... }:
let
  # Armada's UCM for the tablet; the topology and amplifier firmware are in
  # tb321fu-firmware, from bresilla/devices.
  armada = pkgs.fetchFromGitHub {
    owner = "enij90";
    repo = "armada-tb321fu";
    rev = "903dbdb12dfd909a89aca6ca8a90860931c9f2ad";
    sparseCheckout = [
      "system_files/usr/share/alsa/ucm2/Qualcomm/sm8650/TB321FU"
      "system_files/usr/share/alsa/ucm2/conf.d/sm8650"
    ];
    hash = "sha256-nxuwc/9kxxnVsGONlh/BmzVluOghLJbUiEB1S+z7KHc=";
  };
  # alsa-lib finds UCM through ALSA_CONFIG_UCM2, so no ALSA package is rebuilt.
  ucm = pkgs.runCommand "tb321fu-alsa-ucm" { } ''
    mkdir -p $out/share/alsa
    cp -r --no-preserve=mode ${pkgs.alsa-ucm-conf}/share/alsa/ucm2 $out/share/alsa/ucm2
    cp -r --no-preserve=mode ${armada}/system_files/usr/share/alsa/ucm2/. $out/share/alsa/ucm2/
  '';
  ucmPath = "${ucm}/share/alsa/ucm2";
in
{
  environment.variables.ALSA_CONFIG_UCM2 = ucmPath;
  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = ucmPath;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = ucmPath;
}
