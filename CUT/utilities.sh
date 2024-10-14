#!/bin/sh

. usr/local/CUT/common.sh
. usr/local/CUT/utilities/fwmp.sh
. usr/local/CUT/utilities/gbb.sh
. usr/local/CUT/utilities/kernver.sh
. usr/local/CUT/utilities/pencilloop.sh
. usr/local/CUT/utilities/wireless.sh
. usr/local/CUT/utilities/fwutil.sh
. usr/local/CUT/utilities/reset-kern-rollback.sh



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
        "Mr. Chromebox firmware utility script (requires wireless connection)" \
        "Set GBB flags" \
        "Remove FWMP (requires boot from NOFWMP dev mode)" \
        "Set FWMP flags (requires boot from NOFWMP dev mode)" \
        "Set kernver" \
        "AP WP disable loop" \
        "Connect to a WPA wireless network"
    )
    case $sel in
      1) mrchromebox;;
      2) set_gbb_flags;;
      3) clear_fwmp;;
      4) set_fwmp_flags;;
      5) kvs;;
      6) pencilloop;;
      7) connect_wireless;;
      8) crap;;
      *) run=false
    esac
  done
}
