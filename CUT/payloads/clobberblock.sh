#!/bin/sh
. usr/local/CUT/common.sh
clear
logo

echo "This script will remove the secondary kernel and rootfs utilized for ChromeOS' update mechanism"
echo "${red}You will not be able to undo this without restoring with a recovery USB${white}"
echo "Press enter to continue, ctrl+C to cancel"
read a
fdisk /dev/mmcblk0 <<EOF #credit to Hannah for this bit
d
4
d
5
EOF
echo "Success! Your Chromebook can now no longer update"
read a
