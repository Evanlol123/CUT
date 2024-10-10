#!/bin/sh

# I include all of these so I get syntax errors when the script starts, rather than having to hunt around for them
. usr/local/CUT/common.sh
. usr/local/CUT/hwinfo.sh
. usr/local/CUT/utilities.sh
. usr/local/CUT/payloads.sh
. usr/local/CUT/credits.sh
. usr/local/CUT/docs.sh

setup

mount /dev/mmcblk0p1 /mnt
if [ -f /mnt/.fwmp-remove ]; then
  status "FWMP removal directive detected"
  status "Clearing FWMP"
  clear_fwmp
  rm /mnt/.fwmp-remove
  umount /mnt
  status "Rebooting in 5"
  reboot
fi

while :; do
  clear
  logo
  res=$(
    selectorLoop 0 \
      "Hardware/software info" \
      "Payloads" \
      "Utilities" \
      "Documentation" \
      "Credits" \
      "Shell" \
      "Reboot"
  )
  case $res in
    1) hw_info;;
    2) payloads;;
    3) utilities;;
    4) docs;;
    5) sh;;
    6) credits;;
    7) cleanup; exit;;
  esac
done
