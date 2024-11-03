touch_developer_mode() {
local cros_dev="$(get_largest_cros_blockdev)"
	if [ -z "$cros_dev" ]; then
		echo "No CrOS SSD found on device!"
		return 1
	fi
	echo "This will bypass the 5 minute developer mode delay on ${cros_dev}"
	echo "Continue? (y/N)"
	read -r action
	case "$action" in
		[yY]) : ;;
		*) return ;;
	esac
	local stateful=$(format_part_number "$cros_dev" 1)
	local stateful_mnt=$(mktemp -d)
	mount "$stateful" "$stateful_mnt"
	touch "$stateful_mnt/.developer_mode"
	umount "$stateful_mnt"
	rmdir "$stateful_mnt"
 }
