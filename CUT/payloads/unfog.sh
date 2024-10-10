#!/bin/bash

format_part_number() {
  echo -n "$1"
  echo "$1" | grep -q '[0-9]$' && echo -n p
  echo "$2"
}

if flashrom --wp-disable; then
	/usr/share/vboot/bin/set_gbb_flags.sh 0x80b1
	crossystem block_devmode=0
	vpd -i RW_VPD block_devmode=0
	echo "GBB flags set. Devmode should now be unblocked"
 	echo "Would you like to skip the 5 minute developer mode delay? (y/N)"
  	read -r action
   	case "$action" in
    	 [yY]) : ;;
    	 *) return ;;
  	esac
     	local 
  	cros_dev="$(get_largest_cros_blockdev)"
 	if [ -z "$cros_dev" ]; then
    	 echo "No CrOS SSD found on device!"
   	 return 1
  	fi
     	local stateful=$(format_part_number "$cros_dev" 1)
  	local stateful_mnt=$(mktemp -d)
  	mount "$stateful" "$stateful_mnt"
  	touch "$stateful_mnt/.developer_mode"
  	umount "$stateful_mnt"
  	rmdir "$stateful_mnt"
else
	echo "Could not disable software WP"
	exit 1
fi
