#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAED_MAKEFILE="$ROOT_DIR/patches/daed/Makefile"

[ -f "$DAED_MAKEFILE" ] || { echo "missing daed Makefile patch"; exit 1; }

grep -Fq 'HOST_GO:=$(STAGING_DIR_HOSTPKG)/bin/go' "$DAED_MAKEFILE" || {
  echo "daed Makefile does not define an explicit host go binary"
  exit 1
}

grep -Fq '$(HOST_GO) get -u=patch' "$DAED_MAKEFILE" || {
  echo "daed Makefile does not use host go for go get"
  exit 1
}

grep -Fq '$(HOST_GO) mod tidy' "$DAED_MAKEFILE" || {
  echo "daed Makefile does not use host go for go mod tidy"
  exit 1
}

grep -Fq '$(HOST_GO) generate ./...' "$DAED_MAKEFILE" || {
  echo "daed Makefile does not use host go for go generate"
  exit 1
}

if grep -Eq '(^|[;[:space:]])go (get -u=patch|mod tidy|mod edit|generate )' "$DAED_MAKEFILE"; then
  echo "daed Makefile still uses bare go commands"
  exit 1
fi

echo "daed host go test passed"
