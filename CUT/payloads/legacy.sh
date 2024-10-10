#!/bin/bash
vpd -i RW_VPD -s check_enrollment=0
echo "Unblocking devmode..."
vpd -i RW_VPD -s block_devmode=0
crossystem block_devmode=0
local res
res=$(cryptohome --action=get_firmware_management_parameters 2>&1)
if [ $? -eq 0 ] && ! echo "$res" | grep -q "Unknown action"; then
	  tpm_manager_client take_ownership
	  cryptohome --action=remove_firmware_management_parameters
fi
