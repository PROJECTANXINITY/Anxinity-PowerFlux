#!/system/bin/sh
umask 022

MODPATH=${MODPATH:-/data/adb/modules/anxinity_powerflux}

print_line() {
  ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

ui_print ""
print_line
ui_print "⌬  A N X I N I T Y   P O W E R F L U X  ⌬"
ui_print "      Advanced Watt Control Engine"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print ""
ui_print "• Initializing module..."
ui_print "• Preparing PowerFlux engine..."
ui_print "• Optimizing energy flow..."
ui_print ""

[ -d "$MODPATH/common" ] || mkdir -p "$MODPATH/common"
[ -d "$MODPATH/scripts" ] || mkdir -p "$MODPATH/scripts"
[ -d "$MODPATH/webroot" ] || mkdir -p "$MODPATH/webroot"

set_perm_recursive "$MODPATH" 0 0 0755 0644 || true

ui_print "✓ Anxinity PowerFlux installed."
ui_print "✓ Configure via KernelSU WebUI / PowerFlux UI panel."
ui_print ""
print_line
ui_print "Follow updates on GitHub ⭐"
print_line
ui_print ""
