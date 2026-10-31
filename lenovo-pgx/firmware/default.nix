{
  runCommand,
  fetchurl,
  libarchive,
}:

let
  # Must stay the driver lenovo-pgx runs: the open module loads only its own GSP firmware.
  version = "595.104.02";
  installer = fetchurl {
    url = "https://us.download.nvidia.com/XFree86/aarch64/${version}/NVIDIA-Linux-aarch64-${version}.run";
    hash = "sha256-PafStmwNMufeDp3VtpTGGCoW+53Gor/mieO1m1pI7gI=";
  };
in
runCommand "nvidia-gsp-firmware-${version}" { nativeBuildInputs = [ libarchive ]; } ''
  # Unpacked as nixpkgs does: the installer's own extractor needs a host loader.
  skip=$(sed 's/^skip=//; t; d' ${installer})
  tail -n +"$skip" ${installer} | bsdtar xf -
  install -Dm644 -t "$out/lib/firmware/nvidia/${version}" firmware/*.bin
''
