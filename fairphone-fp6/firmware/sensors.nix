{ lib, runCommand }:

# Userspace DSP files, separate from the boot firmware.
runCommand "fp6-sensor-firmware"
  {
    meta.license = lib.licenses.unfree;
  }
  ''
    mkdir -p "$out/dsp"
    cp -r ${./blobs/hexagonfs}/{sensors,socinfo} "$out/"
    cp -r ${./blobs/hexagonfs}/dsp/adsp "$out/dsp/"
  ''
