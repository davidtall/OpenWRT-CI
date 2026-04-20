#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENERAL="$ROOT_DIR/Config/GENERAL.txt"
PACKAGES="$ROOT_DIR/Scripts/Packages.sh"
SETTINGS="$ROOT_DIR/Scripts/Settings.sh"

[ -f "$GENERAL" ] || { echo "missing GENERAL config"; exit 1; }
[ -f "$PACKAGES" ] || { echo "missing Packages.sh"; exit 1; }
[ -f "$SETTINGS" ] || { echo "missing Settings.sh"; exit 1; }

grep -q '^CONFIG_PACKAGE_luci-app-tailscale-community=y$' "$GENERAL" || {
  echo "GENERAL config does not enable luci-app-tailscale-community"
  exit 1
}

if grep -q '^CONFIG_PACKAGE_luci-app-tailscale=y$' "$GENERAL"; then
  echo "GENERAL config still enables luci-app-tailscale"
  exit 1
fi

grep -q '^CONFIG_PACKAGE_luci-app-dae=y$' "$GENERAL" || {
  echo "GENERAL config does not enable luci-app-dae"
  exit 1
}

grep -q '^CONFIG_PACKAGE_luci-app-daed=y$' "$GENERAL" || {
  echo "GENERAL config does not enable luci-app-daed"
  exit 1
}

grep -q '^UPDATE_PACKAGE "luci-app-daed" "QiuSimons/luci-app-daed" "master"$' "$PACKAGES" || {
  echo "Packages.sh does not align luci-app-daed to the upstream source"
  exit 1
}

grep -q 'UPDATE_PACKAGE "gecoosac" "laipeng668/luci-app-gecoosac" "main"' "$PACKAGES" || {
  echo "Packages.sh does not align gecoosac to the upstream source"
  exit 1
}

grep -q '^echo "CONFIG_PACKAGE_luci-app-\$WRT_THEME-config=y" >> \./\.config$' "$SETTINGS" || {
  echo "Settings.sh does not auto-enable the selected theme config package"
  exit 1
}

echo "upstream plugin alignment test passed"
