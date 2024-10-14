#!/bin/sh

. usr/local/CUT/common.sh
. usr/local/CUT/utilities/fwmp.sh
. usr/local/CUT/utilities/gbb.sh
. usr/local/CUT/utilities/kernver.sh
. usr/local/CUT/utilities/pencilloop.sh
. usr/local/CUT/utilities/wireless.sh

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
      1) set_gbb_flags;;
      2) clear_fwmp;;
      3) set_fwmp_flags;;
      4) set_kernver 0x000000;;
      5) pencilloop;;
      6) connect_wireless;;
      *) run=false
    esac
  done
}
