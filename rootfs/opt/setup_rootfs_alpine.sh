#!/bin/sh

#setup the alpine linux rootfs
#this is meant to be run within the chroot created by build_rootfs.sh

DEBUG="$1"
set -e
if [ "$DEBUG" ]; then
  set -x
fi

hostname="$4"
arch="${10}"

#set hostname and apk repos
echo "$hostname" > /etc/hostname

#install base packages
echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories # needed for tpm2-tools
apk add wpa_supplicant vboot-utils curl tpm2-tools cryptsetup

apk del apk-tools
#debloat the system
rm -rf /lib/rc
rm -rf /var/cache
rm /sbin/eapol_test
rm /usr/lib/libstdc++* /usr/lib/libunistring* #this may break things, needs testing
rm -rf /usr/share/vboot #signing stuff that we don't need
