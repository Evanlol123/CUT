#!/bin/sh

. usr/local/CUT/common.sh

hw_info() {
  mount -o ro /dev/mmcblk0p3 /mnt
  rootfs1ver=$(cat /mnt/etc/os-release | sed -n '7p' | grep -o "[0-9]*")
  umount /mnt

  mount -o ro /dev/mmcblk0p5 /mnt
  rootfs2ver=$(cat /mnt/etc/os-release | sed -n '7p' | grep -o "[0-9]*")
  umount /mnt

  device_path=/sys/class/dmi/id/
  clear
  logo
  echo -e "${green}Hardware/software information${white}"
  echo "Board type: $(cat $device_path/product_family)"
  echo "Device codename: $(cat $device_path/board_name)"
  echo "Firmware version: $(cat $device_path/bios_version)"
  echo "Firmware date: $(cat $device_path/bios_date)"
  echo "Board revision: $(cat $device_path/board_version)"
  echo
  echo "ChromeOS rootfs A (/dev/mmcblk0p3) version: ${rootfs1ver}" 
  echo "ChromeOS rootfs B (/dev/mmcblk0p5) version: ${rootfs2ver}"
  echo "GBB flags: $(get_gbb_flags.sh 2>&1 | grep -o "0x[^ ]*" | tail -1)"
  echo "FWMP status: $()" # Make a raw extraction script at a later date 
  echo "WP status: $(get_wp_status)"
  read a
}
