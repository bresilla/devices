#!/usr/bin/env bash
# Run as root on the images from .#tb321fu-images: adds this computer's active Wi-Fi
# connection and a login password to a copy of the root filesystem, then sparses it
# for fastboot. Neither enters the image, the Nix store or the repository.
set -euo pipefail

images=${1:?usage: provision.sh <tb321fu-images output> <work dir> [username]}
work=${2:?usage: provision.sh <tb321fu-images output> <work dir> [username]}
user=${3:-${SUDO_USER:-}}
[[ $EUID == 0 ]] || { echo "provision.sh: run as root" >&2; exit 1; }

mkdir -p "$work"
cp --no-preserve=mode "$images/boot.img" "$images/super.img" "$work/"
zstd -dc "$images/userdata.img.zst" > "$work/userdata.img"

mnt=$(mktemp -d)
trap 'umount "$mnt" 2>/dev/null || true; rmdir "$mnt"' EXIT
mount -o loop "$work/userdata.img" "$mnt"

# Active Wi-Fi connection, as a NetworkManager keyfile.
connections=$mnt/etc/NetworkManager/system-connections
mkdir -p "$connections"
chmod 700 "$connections"
while IFS=: read -r name type; do
  [[ $type == 802-11-wireless ]] || continue
  file=$(grep -lx "id=$name" /etc/NetworkManager/system-connections/*.nmconnection | head -1)
  [[ -n $file ]] || continue
  sed '/^interface-name=/d' "$file" > "$connections/$(basename "$file")"
  chmod 600 "$connections/$(basename "$file")"
  echo "copied Wi-Fi connection: $name"
done < <(nmcli -t -f NAME,TYPE con show --active)

# Activation keeps an existing hash for undeclared passwords.
if [[ -n $user ]] && read -rsp "Password for $user on the tablet (empty skips): " password && echo && [[ -n $password ]]; then
  hash=$(openssl passwd -6 -stdin <<< "$password")
  printf '%s:%s:1::::::\n' "$user" "$hash" > "$mnt/etc/shadow"
  chmod 600 "$mnt/etc/shadow"
  echo "set the password for $user"
fi

sync
umount "$mnt"
img2simg "$work/userdata.img" "$work/userdata.simg"
rm "$work/userdata.img"
echo "ready to flash: $work"
