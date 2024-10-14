#!/bin/sh

. usr/local/CUT/common.sh

clear_fwmp () {
  # Also check if it's booted through dev mode instead of os_verif=0, otherwise the TPM won't allow for it
  # add custom TPM ownership script
  crypthome --remove-firmware-management-parameters 
  read a
}

set_fwmp_flags () {
  read -p "FWMP flags to set: " flags
  crypthome --action=set_firmware_management_parameters --flags=$flags # Replace with custom FWMP script 
  read a
}
