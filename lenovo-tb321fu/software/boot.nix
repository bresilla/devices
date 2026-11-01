{ lib, pkgs, ... }:

let
  dtbs = [
    "sm8650-lenovo-tb321fu"
    "sm8650-lenovo-tb321fu-csot"
  ];
  # Writes a generation onto the FAT: kernel, initrd, both panels' DTBs and the GRUB
  # menu. The previous generation stays in its own folder as the rollback entry.
  installFiles = pkgs.writeShellScript "tb321fu-boot-files" ''
    set -euo pipefail
    toplevel=$1 boot=$2
    init="$toplevel/init"
    cmdline="init=$init $(< "$toplevel/kernel-params")"
    mkdir -p "$boot/current/dtb"
    if [ -e "$boot/current/Image" ] && ! cmp -s "$boot/current/cmdline" <(echo "$cmdline"); then
      rm -rf "$boot/previous"
      mv "$boot/current" "$boot/previous"
      mkdir -p "$boot/current/dtb"
    fi
    cp -f "$toplevel/kernel" "$boot/current/Image"
    cp -f "$toplevel/initrd" "$boot/current/initramfs.img"
    ${lib.concatMapStrings (dtb: ''
      cp -f "$toplevel/dtbs/qcom/${dtb}.dtb" "$boot/current/dtb/${dtb}.dtb"
    '') dtbs}
    echo "$cmdline" > "$boot/current/cmdline"

    entry() {
      local folder=$1 label=$2 dtb=$3 line
      line=$(< "$boot/$folder/cmdline")
      printf 'menuentry "%s" {\n  devicetree /%s/dtb/%s.dtb\n  linux /%s/Image %s\n  initrd /%s/initramfs.img\n}\n\n' \
        "$label" "$folder" "$dtb" "$folder" "$line" "$folder"
    }
    # `touch /boot/panel-csot` on a CSOT unit puts its entry first.
    if [ -e "$boot/panel-csot" ]; then
      first=sm8650-lenovo-tb321fu-csot second=sm8650-lenovo-tb321fu
    else
      first=sm8650-lenovo-tb321fu second=sm8650-lenovo-tb321fu-csot
    fi
    {
      printf 'set timeout=3\nset default=0\nset gfxpayload=keep\n\n'
      entry current "NixOS" "$first"
      entry current "NixOS (other panel)" "$second"
      if [ -e "$boot/previous/Image" ]; then
        entry previous "NixOS, previous generation" "$first"
      fi
      printf 'menuentry "Power off" {\n  halt\n}\n'
    } > "$boot/boot/grub/grub.cfg.new"
    mv -f "$boot/boot/grub/grub.cfg.new" "$boot/boot/grub/grub.cfg"
    sync
  '';
in
{
  boot.loader.grub.enable = false;
  boot.loader.external = {
    enable = true;
    # Bootloader hooks run with an empty PATH.
    installHook = pkgs.writeShellScript "tb321fu-install-kernel" ''
      set -euo pipefail
      export PATH=${
        lib.makeBinPath (
          with pkgs;
          [
            bash
            coreutils
            diffutils
            util-linux
          ]
        )
      }
      mountpoint -q /boot || {
        echo "tb321fu: /boot is not mounted; refusing to write the kernel" >&2
        exit 1
      }
      ${installFiles} "$1" /boot
    '';
  };

  systemd.tpm2.enable = false;
  boot.initrd.systemd = {
    enable = true;
    tpm2.enable = false;
  };

  system.build.tb321fuBootFiles = installFiles;
}
