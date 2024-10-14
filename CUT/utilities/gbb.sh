#!/bin/bash
echo "What do you want your GBB flags to be set to?"
echo "0x80b1 is recommended"
read flags
if flashrom --wp-disable; then
    /usr/share/vboot/bin/set_gbb_flags.sh "$flags"
    echo "GBB flags set to $flags."
else
    echo "Could not disable software WP"
fi
exit 1
