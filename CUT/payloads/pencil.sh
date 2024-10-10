#!/bin/sh
. usr/local/CUT/common.sh
. usr/local/CUT/utilities/kernver.sh 
. usr/local/CUT/utilities/pencilloop.sh
clear
logo

status "Disabling firmware write-protect"
pencilloop
status "Setting GBB flags to 0x80b9"
set_gbb_flags.sh 0x80b9
status "Resetting kernver"
echo "0x000000" | set_kernver 
status "Setting CUT to disable FWMP on boot"
mount /dev/mmcblk0p1 /mnt
touch /mnt/.fwmp-remove
umount /mnt
echo "${green}${bold}You aren't done yet!${unbold}"
echo "After your device enters dev mode, instead of pressing ctrl+d to boot ChromeOS, press ctrl+u with this USB plugged in"
echo "This will take ${underline}TPM${nounderline} ownership and disable ${underline}FWMP${nounderline}"
read a
reboot
