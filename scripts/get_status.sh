#!/system/bin/sh
MODDIR=${0%/*}/..
. "$MODDIR/common/config.sh"
. "$MODDIR/common/functions.sh"

load_nodes

CUR_PROFILE=$(get_profile_watt)
CUR_UA=$(get_current_ua)
CUR_UV=$(get_voltage_uv)
CUR_W=$(calc_watt_from_sysfs "$CUR_UA" "$CUR_UV")

cat <<EOF
profile_watt=${CUR_PROFILE:-0}
current_ua=${CUR_UA:-0}
voltage_uv=${CUR_UV:-0}
current_watt=${CUR_W:-0}
node_current=${CHG_CURRENT_NODE:-none}
EOF
