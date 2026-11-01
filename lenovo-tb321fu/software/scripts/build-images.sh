#!/usr/bin/env bash
# Rebuilds the tablet images in a throwaway clone. Run on an aarch64 builder such as lama.
set -euo pipefail
work=/var/tmp/lego-build
rm -rf "$work"
git clone -q https://github.com/bresilla/nixos "$work"
cd "$work"
cp /etc/nixos/user.nix .
printf '{ profile = "handheld"; device = "lenovo-tb321fu"; }\n' > machine.nix
curl -fsSL https://cache.bresilla.com/-/pins > /var/tmp/lego-pins.json
sed -i 's/if (( EUID != 0 )) \&\& \[\[ -S \/nix\/var\/nix\/daemon-socket\/socket \]\]; then/if false; then/' shared/installer/cache-binaries.sh
bash shared/installer/cache-binaries.sh "$work" aarch64-linux /var/tmp/lego-pins.json
nix build --accept-flake-config --out-link /var/tmp/lego-result "path:$work#packages.aarch64-linux.tb321fu-images" -L
ls -la /var/tmp/lego-result/
echo LEGO-BUILD-DONE
