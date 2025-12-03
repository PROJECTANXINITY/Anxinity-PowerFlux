#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common/config.sh"

mkdir -p "$(dirname "$CFG_FILE")"
if [ ! -f "$CFG_FILE" ]; then
  echo "profile_watt=33" > "$CFG_FILE"
  log "Default profile created: 33W"
fi
