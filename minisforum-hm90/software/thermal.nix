# The HM90's Ryzen 9 4900H runs without turbo boost: in this small box short bursts
# reached 78-90 °C with it, and it sits at 40-50 °C without (3.3 GHz instead of 4.4;
# measured 2026-11-22). Single jobs run up to a quarter slower.
{
  systemd.tmpfiles.rules = [ "w /sys/devices/system/cpu/cpufreq/boost - - - - 0" ];
}
