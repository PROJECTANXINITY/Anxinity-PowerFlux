#!/system/bin/sh

MODDIR=${0%/*}
CFG_DIR=/data/adb/anxinity_powerflux
CFG_FILE="$CFG_DIR/config.properties"
LOG_FILE="$CFG_DIR/log.txt"

mkdir -p "$CFG_DIR"

# default config
[ -f "$CFG_FILE" ] || echo "profile_watt=33" > "$CFG_FILE"

get_profile_watt() {
  awk -F= '/^profile_watt/ {print $2}' "$CFG_FILE" 2>/dev/null | tr -d '\r\n'
}

set_profile_watt() {
  local W=$1
  if [ -z "$W" ]; then
    return 1
  fi
  if grep -q '^profile_watt=' "$CFG_FILE" 2>/dev/null; then
    sed -i "s/^profile_watt=.*/profile_watt=$W/" "$CFG_FILE" 2>/dev/null
  else
    echo "profile_watt=$W" >> "$CFG_FILE"
  fi
}
