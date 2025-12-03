#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common/config.sh"
PATHS_CONF="$MODDIR/common/paths.conf"

log() {
  echo "$(date '+%F %T') [ANX-FLX] $*" >> "$LOG_FILE"
}

load_nodes() {
  [ -f "$PATHS_CONF" ] || return 1
  . "$PATHS_CONF"
}

detect_nodes() {
  # If already detected, keep existing
  if [ -f "$PATHS_CONF" ] && grep -q 'CHG_CURRENT_NODE' "$PATHS_CONF" 2>/dev/null; then
    return 0
  fi

  log "Detecting charging sysfs nodes..."
  local candidates="
/sys/class/power_supply/battery/constant_charge_current_max
/sys/class/power_supply/battery/constant_charge_current
/sys/class/power_supply/battery/input_current_limit
/sys/class/power_supply/main/current_max
/sys/class/power_supply/usb/current_max
/sys/class/power_supply/charger/current_now
/sys/class/power_supply/usb/current_now
"

  local node_current=""
  for p in $candidates; do
    if [ -f "$p" ]; then
      node_current="$p"
      break
    fi
  done

  if [ -z "$node_current" ]; then
    log "No known charge current node found."
    return 1
  fi

  cat > "$PATHS_CONF" <<EOF
CHG_CURRENT_NODE="$node_current"
EOF

  log "Detected CHG_CURRENT_NODE=$node_current"
}

# Convert Watt -> microampere assuming 5V nominal (approx)
watt_to_ua() {
  local W=$1
  # integer math: (W * 1_000_000 / 5)
  echo $(( (W * 1000000) / 5 ))
}

apply_current_profile() {
  load_nodes || detect_nodes || return 1

  local WATT
  WATT=$(get_profile_watt)
  [ -z "$WATT" ] && WATT=33

  local UA
  UA=$(watt_to_ua "$WATT")
  [ -z "$CHG_CURRENT_NODE" ] && return 1

  if [ -w "$CHG_CURRENT_NODE" ]; then
    echo "$UA" > "$CHG_CURRENT_NODE" 2>/dev/null && \
      log "Applied profile ${WATT}W -> ${UA}µA to $CHG_CURRENT_NODE"
  else
    log "CHG_CURRENT_NODE not writable: $CHG_CURRENT_NODE"
  fi
}

get_current_ua() {
  load_nodes || return 0
  [ -f "$CHG_CURRENT_NODE" ] || return 0
  cat "$CHG_CURRENT_NODE" 2>/dev/null
}

get_voltage_uv() {
  local v_candidates="
/sys/class/power_supply/battery/voltage_now
/sys/class/power_supply/charger/voltage_now
/sys/class/power_supply/usb/voltage_now
"
  local v=""
  for p in $v_candidates; do
    if [ -f "$p" ]; then
      v=$(cat "$p" 2>/dev/null)
      [ -n "$v" ] && break
    fi
  done
  echo "${v:-0}"
}

calc_watt_from_sysfs() {
  local ua=$1
  local uv=$2
  [ -z "$ua" ] && ua=0
  [ -z "$uv" ] && uv=0
  # P(W) = (ua * uv) / 1e12
  echo $(( ua * uv / 1000000 / 1000000 ))
}
