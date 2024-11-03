#!/bin/sh
. usr/local/CUT/common.sh
clear
logo

echo "This script will remove the secondary kernel and rootfs utilized for ChromeOS' update mechanism"
echo "${red}You will not be able to undo this without restoring with a recovery USB${white}"
echo "Press enter to continue, ctrl+C to cancel"
read a
cgpt add /dev/mmcblk0 -i 2 -P 10 -T 5 -S 1
cat << EOF | fdisk /dev/mmcblk0
d
4

d
5

d
1

n
1


w
EOF
yes | mkfs.ext4 /dev/mmcblk0p1
echo "Success! Your Chromebook can now no longer update"
read a
