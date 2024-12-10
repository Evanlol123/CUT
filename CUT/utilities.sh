#!/bin/sh

. usr/local/CUT/common.sh
. usr/local/CUT/utilities/fwmp.sh
. usr/local/CUT/utilities/gbb.sh
. usr/local/CUT/utilities/kernver.sh
. usr/local/CUT/utilities/pencilloop.sh
. usr/local/CUT/utilities/wireless.sh
. usr/local/CUT/utilities/fwutil.sh
. usr/local/CUT/utilities/reset-kern-rollback.sh
. usr/local/CUT/utilities/clobberblock.sh
. usr/local/CUT/utilities/crap.sh
. usr/local/CUT/utilities/touch_developer_mode.sh
. usr/local/CUT/utilities/enable_usb_boot.sh




utilities () {
  local run=true
  while $run; do
    clear
    logo
    wp_status=$(get_wp_status)
    echo "$green All of these utilities require WP to be disabled$white"
    echo "$red Current WP status: $wp_status $white"
    sel=$(
      selectorLoop 1 \
        "Open a bash shell" \
        "Mr. Chromebox firmware utility script" \
        "Set GBB flags" \
        "Remove FWMP (requires boot from NOFWMP dev mode)" \
        "Set FWMP flags (requires boot from NOFWMP dev mode)" \
        "Set kernver" \
        "Pencil WP disable loop" \
        "Connect to a WPA wireless network" \
        "Clobber Based Chrome OS Update Blocker (DAUB)" \
        "Skip 5 minute transition to devmode wait" \
        "Enable USB/altfw boot" \
    )
    case $sel in
      1) bash ;;
      2) mrchromebox;;
      3) set_gbb_flags;;
      4) clear_fwmp;;
      5) set_fwmp_flags;;
      6) kvs;;
      7) pencilloop;;
      8) connect_wireless;;
      9) crap;;
      10) blockupdates
      11) touch_developer_mode
      12) enable_usb_boot
      *) run=false
    esac
  done
}
