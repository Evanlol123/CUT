#!/bin/bash

enable_usb_boot() {
	echo "Enabling USB/altfw boot..."
	crossystem dev_boot_usb=1
	crossystem dev_boot_legacy=1 || :
	crossystem dev_boot_altfw=1 || :
}
