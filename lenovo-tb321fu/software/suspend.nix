{ lib, pkgs, ... }:
let
  # Seconds the display must stay blanked before the tablet sleeps. A wake
  # that leaves it blanked, such as a charger event, restarts the count.
  delay = 60;
  autosuspend = pkgs.writeShellApplication {
    name = "tb321fu-autosuspend";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      systemd
    ];
    text = ''
      screen_on() {
        local power
        for power in /sys/class/backlight/*/bl_power; do
          [[ $(cat "$power") == 0 ]] && return 0
        done
        return 1
      }
      # Music with the display off keeps a PCM running.
      audio_running() {
        grep -qs 'state: RUNNING' /proc/asound/card*/pcm*/sub*/status
      }
      suspends() { cat /sys/power/suspend_stats/success; }

      blank_since=$SECONDS
      last=$(suspends)
      while sleep 10; do
        now=$(suspends)
        if [[ $now != "$last" ]] || screen_on || audio_running; then
          last=$now
          blank_since=$SECONDS
          continue
        fi
        if (( SECONDS - blank_since >= ${toString delay} )); then
          systemctl suspend || true
          blank_since=$SECONDS
        fi
      done
    '';
  };
in
{
  # As on the phone: the power key only blanks the display, so this suspends it.
  systemd.sleep.settings.Sleep.MemorySleepMode = "s2idle";

  systemd.services.tb321fu-autosuspend = {
    description = "Suspend the tablet while its display is blanked";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.getExe autosuspend;
      Restart = "always";
      RestartSec = 10;
    };
  };
}
