{
  lib,
  runCommand,
  m4,
  alsa-utils,
}:

runCommand "fp6-audio-firmware"
  {
    nativeBuildInputs = [
      m4
      alsa-utils
    ];
    meta.license = lib.licenses.unfree;
  }
  ''
    mkdir -p "$out/lib/firmware/qcom/milos/fairphone/fp6"
    m4 -I ${./topology} ${./topology}/MILOS-Fairphone-Gen6.m4 > fp6.conf
    alsatplg -c fp6.conf -o "$out/lib/firmware/qcom/milos/MILOS-Fairphone-Gen6-tplg.bin"
    cp ${./blobs/aw882xx_acf.bin} \
      "$out/lib/firmware/qcom/milos/fairphone/fp6/aw88261_acf.bin"
  ''
