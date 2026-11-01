# The Legion Tab Gen 3 kernel: kernel.org stable with the patch series and device
# trees of Armada for the TB321FU.
# Its nixpkgs is pinned apart from the system's, so updates never rebuild the kernel.
{
  buildSystem ? "aarch64-linux",
}:

let
  version = "7.2.6";
  nixpkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/2c423e03bbafcff28bfadc6781a4a8257f205cb5.tar.gz";
    sha256 = "0sncav0zwd301731dh1pqdfgwiak5af6b5gg178wy0zcrdsidpkn";
  };
  pkgs =
    if buildSystem == "aarch64-linux" then
      import nixpkgsSrc { system = "aarch64-linux"; }
    else
      import nixpkgsSrc {
        localSystem = buildSystem;
        crossSystem = "aarch64-linux";
      };
  inherit (pkgs) lib;

  armadaRev = "903dbdb12dfd909a89aca6ca8a90860931c9f2ad";
  armada =
    paths: hash:
    pkgs.fetchFromGitHub {
      owner = "enij90";
      repo = "armada-tb321fu";
      rev = armadaRev;
      sparseCheckout = paths;
      inherit hash;
    };
  armadaKernel = armada [ "packages/kernel" ] "sha256-cpL/+tju0OXubWiT/jpNAVq2XHGStFvrIpNPeXPX1UE=";

  # Patched tree, as Armada's scripts/build-kernel.sh prepares it.
  source = pkgs.buildPackages.stdenvNoCC.mkDerivation {
    pname = "linux-tb321fu-source";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-${version}.tar.xz";
      hash = "sha256-A5rvhPKwmUrto/T8/D0C7J16m7uQIOomTEP0Rshg9gY=";
    };
    kernel = "${armadaKernel}/packages/kernel";
    buildPhase = ''
      runHook preBuild
      while IFS= read -r line; do
        line="''${line%%#*}"
        read -r name _ <<< "$line" || true
        [ -n "''${name:-}" ] || continue
        echo "applying $name"
        patch -p1 --batch --forward -F0 --no-backup-if-mismatch --quiet < "$kernel/patches/$name"
      done < "$kernel/patches/series"
      qcom=arch/arm64/boot/dts/qcom
      cp "$kernel"/dts/*.dts "$kernel"/dts/*.dtsi "$qcom/"
      chmod -R u+w "$qcom"
      for p in "$kernel"/dts/*.patch; do
        patch -p1 -F0 --no-backup-if-mismatch --quiet < "$p"
      done
      {
        echo
        echo "# armada-kernel DTBs"
        for dts in "$kernel"/dts/*.dts; do
          echo "dtb-\$(CONFIG_ARCH_QCOM) += $(basename "$dts" .dts).dtb"
        done
      } >> "$qcom/Makefile"
      # The AP500U pen reports format 0x02, which the driver would drop.
      sed -i "s/if (pen_format_id == 0x01) {/if (pen_format_id == 0x01 || pen_format_id == 0x02) {/" \
        drivers/input/touchscreen/nt36523/nt36xxx.c
      runHook postBuild
    '';
    installPhase = "cp -r . $out";
    dontFixup = true;
  };

  # Regenerates kernel.config: defconfig, then Armada's fragment and ours
  # (what NixOS needs), as Armada merges it.
  config = pkgs.stdenv.mkDerivation {
    pname = "linux-tb321fu-config";
    inherit version;
    src = source;
    depsBuildBuild = [ pkgs.buildPackages.stdenv.cc ];
    nativeBuildInputs = with pkgs.buildPackages; [
      bc
      bison
      flex
      perl
      python3
      pahole
    ];
    makeFlags = [
      "ARCH=arm64"
      "CROSS_COMPILE=${pkgs.stdenv.cc.targetPrefix}"
    ];
    buildPhase = ''
      runHook preBuild
      patchShebangs scripts
      make $makeFlags defconfig
      cat ${armadaKernel}/packages/kernel/config/armada-kernel.config.overrides ${./fragment} \
        | sed -E '/^[[:space:]]*CONFIG_[A-Z0-9_]+=/ s/[[:space:]]*#.*$//' > fragment
      ARCH=arm64 CROSS_COMPILE=${pkgs.stdenv.cc.targetPrefix} \
        bash scripts/kconfig/merge_config.sh -m .config fragment
      make $makeFlags olddefconfig
      missing=0
      while IFS= read -r requested; do
        case "$requested" in
          CONFIG_*=y) grep -qx "$requested" .config || { echo "lost: $requested"; missing=1; } ;;
        esac
      done < fragment
      [ "$missing" = 0 ]
      runHook postBuild
    '';
    installPhase = "cp .config $out";
  };

  # Named as before the move, so the kernel keeps its store path.
  configfile = builtins.path {
    path = ./config;
    name = "kernel.config";
  };
  parseLine =
    line:
    let
      match = builtins.match "(CONFIG_[A-Za-z0-9_]+)=(.*)" line;
    in
    lib.optional (match != null) {
      name = builtins.elemAt match 0;
      value = lib.removePrefix "\"" (lib.removeSuffix "\"" (builtins.elemAt match 1));
    };

  kernel = pkgs.linuxKernel.manualConfig {
    inherit version configfile;
    src = source;
    modDirVersion = version;
    config = builtins.listToAttrs (
      lib.concatMap parseLine (lib.splitString "\n" (builtins.readFile configfile))
    );
  };

in
{
  inherit
    source
    config
    kernel
    ;
  dtbs = lib.splitString "\n" (lib.trim (builtins.readFile ./dtbs));
}
