#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAE_MAKEFILE="$ROOT_DIR/package/dae/Makefile"

[ -f "$DAE_MAKEFILE" ] || { echo "missing dae Makefile"; exit 1; }

grep -q '^PKG_MIRROR_HASH:=skip$' "$DAE_MAKEFILE" || {
	echo "dae Makefile is missing PKG_MIRROR_HASH:=skip"
	exit 1
}

grep -q 'git clone -b $(GIT_BRANCH) $(PKG_SOURCE_URL) $(PKG_BUILD_DIR)' "$DAE_MAKEFILE" || {
	echo "dae Build/Prepare does not clone the configured kdae branch"
	exit 1
}

grep -q 'cut -f1' "$DAE_MAKEFILE" || {
	echo "dae Makefile does not resolve the full source revision"
	exit 1
}

grep -q 'rm -rf outbound && git clone --depth=1 -b perf/complete-optimizations https://github.com/olicesx/outbound.git outbound' "$DAE_MAKEFILE" || {
	echo "dae Build/Prepare does not clone the kdae outbound fork inside the source tree"
	exit 1
}

grep -q 'go mod edit -replace github.com/daeuniverse/outbound=./outbound' "$DAE_MAKEFILE" || {
	echo "dae Build/Prepare does not replace outbound with the kdae fork"
	exit 1
}

grep -q 'rm -rf quic-go && git clone --depth=1 -b main https://github.com/olicesx/quic-go.git quic-go' "$DAE_MAKEFILE" || {
	echo "dae Build/Prepare does not clone the kdae quic-go fork inside the source tree"
	exit 1
}

grep -q 'go mod edit -replace github.com/daeuniverse/quic-go=./quic-go' "$DAE_MAKEFILE" || {
	echo "dae Build/Prepare does not replace quic-go with the kdae fork"
	exit 1
}

echo "dae source verification guard test passed"
