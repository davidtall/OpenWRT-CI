#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENERAL_CONFIG="$ROOT_DIR/Config/GENERAL.txt"

[ -f "$GENERAL_CONFIG" ] || { echo "missing GENERAL.txt"; exit 1; }

grep -q '^CONFIG_PACKAGE_luci-app-nikki=y$' "$GENERAL_CONFIG" || {
	echo "GENERAL config does not enable luci-app-nikki"
	exit 1
}

grep -q '^CONFIG_PACKAGE_mihomo-alpha=y$' "$GENERAL_CONFIG" || {
	echo "GENERAL config does not select mihomo-alpha for Nikki"
	exit 1
}

if grep -q '^CONFIG_PACKAGE_mihomo-meta=y$' "$GENERAL_CONFIG"; then
	echo "GENERAL config selects conflicting mihomo-meta"
	exit 1
fi

grep -q '^# CONFIG_PACKAGE_mihomo-meta is not set$' "$GENERAL_CONFIG" || {
	echo "GENERAL config does not explicitly disable mihomo-meta"
	exit 1
}

echo "Nikki mihomo-alpha selection guard test passed"
