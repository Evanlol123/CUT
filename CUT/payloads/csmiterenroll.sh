#!/bin/bash
echo "This will only work if you don't need an admin to enroll your school account"
crossystem disable_dev_request=1
mkfs.ext4 /dev/mmcblk0p1
vpd -i RW_VPD -s check_enrollment=1
