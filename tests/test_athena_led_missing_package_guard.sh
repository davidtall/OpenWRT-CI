#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FUNCTIONS_SH="$ROOT_DIR/Scripts/function.sh"
CONFIG_TEST="$ROOT_DIR/Config/TEST.txt"

[ -f "$FUNCTIONS_SH" ] || { echo "missing function.sh"; exit 1; }
[ -f "$CONFIG_TEST" ] || { echo "missing TEST.txt"; exit 1; }

for pkg in luci-app-athena-led luci-i18n-athena-led-zh-cn; do
	grep -q "$pkg" "$FUNCTIONS_SH" || {
		echo "function.sh does not strip missing per-device package: $pkg"
		exit 1
	}

	if grep -q "^CONFIG_PACKAGE_${pkg}=m$" "$CONFIG_TEST"; then
		echo "TEST config still selects missing package as module: $pkg"
		exit 1
	fi

	if grep -q "^CONFIG_TARGET_DEVICE_PACKAGES_.*${pkg}" "$CONFIG_TEST"; then
		echo "TEST config still injects missing package into a device image: $pkg"
		exit 1
	fi
done

grep -q 'remove_missing_device_packages \$config_file' "$FUNCTIONS_SH" || {
	echo "generate_config does not call remove_missing_device_packages"
	exit 1
}

echo "athena-led missing package guard test passed"
