{ pkgs, ... }:
let
  # One CSV row per run: what the battery is doing, how often the tablet has
  # slept since boot, and which process was busiest over one second.
  battery-log = pkgs.writeShellApplication {
    name = "tb321fu-battery-log";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      procps
    ];
    text = ''
      bat=/sys/class/power_supply/battery
      log=/var/lib/battery-log/battery.csv
      if [ ! -s "$log" ]; then
        echo "time,capacity,status,current_ma,charge_mah,voltage_mv,temp_c,suspends,top_cpu,top_process" > "$log"
      fi
      read_bat() { cat "$bat/$1" 2>/dev/null || echo 0; }
      # The second sample covers the one-second interval, not process lifetime.
      top=$(top -b -n2 -d1 -o %CPU -w 512 | awk '/^ *PID/ { n++; next } n == 2 && $12 != "top" { print $9 "," $12; exit }')
      echo "$(date -Iseconds),$(read_bat capacity),$(read_bat status),$(( $(read_bat current_now) / 1000 )),$(( $(read_bat charge_now) / 1000 )),$(( $(read_bat voltage_now) / 1000 )),$(( $(read_bat temp) / 10 )),$(cat /sys/power/suspend_stats/success),$top" >> "$log"
    '';
  };
in
{
  environment.systemPackages = [ battery-log ];
  systemd.services.tb321fu-battery-log = {
    description = "Log the tablet's battery drain";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${battery-log}/bin/tb321fu-battery-log";
      StateDirectory = "battery-log";
      StateDirectoryMode = "0755";
      UMask = "0022";
    };
  };
  # Calendar time, so a run missed while suspended happens on resume and the
  # gap between rows shows how long the tablet slept.
  systemd.timers.tb321fu-battery-log = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
  };
}
