#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAE_MAKEFILE="$ROOT_DIR/package/dae/Makefile"

[ -f "$DAE_MAKEFILE" ] || { echo "missing dae Makefile"; exit 1; }

grep -q '^PKG_MIRROR_HASH:=skip$' "$DAE_MAKEFILE" || {
	echo "dae Makefile is missing PKG_MIRROR_HASH:=skip"
	exit 1
}

grep -q 'git -C $(PKG_BUILD_DIR) checkout $(PKG_SOURCE_VERSION)' "$DAE_MAKEFILE" || {
	echo "dae Build/Prepare does not checkout PKG_SOURCE_VERSION"
	exit 1
}

echo "dae source verification guard test passed"
