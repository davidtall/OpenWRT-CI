#!/bin/sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MIGRATION_SCRIPT="$ROOT_DIR/files/etc/uci-defaults/99-athena-led-config-migration"

[ -f "$MIGRATION_SCRIPT" ] || {
	echo "missing athena LED config migration script"
	exit 1
}

grep -q "athena_led.config.enable" "$MIGRATION_SCRIPT" || {
	echo "migration script does not detect old athena_led config schema"
	exit 1
}

grep -q "/rom/etc/config/athena_led" "$MIGRATION_SCRIPT" || {
	echo "migration script does not restore the package default config"
	exit 1
}

grep -q "athena_led.config-migrated" "$MIGRATION_SCRIPT" || {
	echo "migration script does not keep a backup of the incompatible config"
	exit 1
}

grep -q "option enabled '1'" "$MIGRATION_SCRIPT" || {
	echo "migration script does not provide a v2.x-compatible fallback config"
	exit 1
}

echo "athena LED config migration guard passed"
