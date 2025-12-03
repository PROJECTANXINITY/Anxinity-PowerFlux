#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common/config.sh"
. "$MODDIR/common/functions.sh"

log "PowerFlux service starting..."

# initial detection (if not already)
detect_nodes

# run loop applying profile periodically
while true; do
  apply_current_profile
  sleep 5
done
