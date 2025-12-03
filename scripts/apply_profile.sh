#!/system/bin/sh
MODDIR=${0%/*}/..
. "$MODDIR/common/config.sh"
. "$MODDIR/common/functions.sh"

W=$1
case "$W" in
  33|45|60|90|120) ;;
  *) echo "invalid"; exit 1 ;;
esac

set_profile_watt "$W"
apply_current_profile
echo "ok"
