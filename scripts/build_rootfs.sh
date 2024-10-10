#!/bin/bash

#build the chosen distribution's rootfs

. ./common.sh

print_help() {
  echo "Usage: ./build_rootfs.sh rootfs_path build_dir"
  echo "Valid named arguments (specify with 'key=value'):"
  echo "  hostname        - The hostname for the new rootfs."
  echo "  arch            - The CPU architecture to build the rootfs for."
  echo "If you do not specify the hostname, you will be prompted for it later."
}

echo "$@"
assert_root
assert_deps "realpath debootstrap findmnt wget pcregrep tar ninja meson clang++"
assert_args "$3"
parse_args "$@"
rootfs_dir=$(realpath -m "${1}")
build_dir=$(realpath -m "${2}")
release_name="minirootfs-3.20"
arch="${args['arch']-amd64}"
chroot_mounts="proc sys dev run"
echo $build_dir

if [ -d "$rootfs_dir" ]; then
  #umount -R "$rootfs_dir"/* # I keep removing my efivars by chrooting in to test 
  rm -r "$rootfs_dir"
fi

mkdir -p $rootfs_dir

unmount_all() {
  for mountpoint in $chroot_mounts; do
    umount -l "$rootfs_dir/$mountpoint"
  done
}

need_remount() {
  local target="$1"
  local mnt_options="$(findmnt -T "$target" | tail -n1 | rev | cut -f1 -d' '| rev)"
  echo "$mnt_options" | grep -e "noexec" -e "nodev"
}

do_remount() {
  local target="$1"
  local mountpoint="$(findmnt -T "$target" | tail -n1 | cut -f1 -d' ')"
  mount -o remount,dev,exec "$mountpoint"
}

if [ "$(need_remount "$rootfs_dir")" ]; then
  do_remount "$rootfs_dir"
fi

print_info "bootstrapping alpine chroot"


real_arch="x86_64"
if [ "$arch" = "arm64" ]; then 
  real_arch="aarch64"
fi
if [ ! -f alpine-minirootfs.tar.gz ]; then
  wget https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-3.20.3-x86_64.tar.gz -O alpine-minirootfs.tar.gz
fi
tar -xf alpine-minirootfs.tar.gz -C $rootfs_dir

print_info "copying rootfs setup scripts"
cp /etc/resolv.conf "$rootfs_dir/etc/resolv.conf"
rm $rootfs_dir/sbin/init #remove the stock init, as it doesn't work
cp -ar ../rootfs/* $rootfs_dir

if [ ! -d shflags ]; then
  git clone https://github.com/kward/shflags
fi

print_info "Building auxilary binaries because ChromeOS just has to be unique"

buildables="flashrom vpd "
for buildscript in $buildables 
do
  echo "Building $buildscript"
  ./buildables/${buildscript}.sh $rootfs_dir $build_dir
done

mkdir $rootfs_dir/usr/share/misc/lib
cp shflags/shflags $rootfs_dir/usr/share/misc/shflags
cp shflags/lib/shunit2 $rootfs_dir/usr/share/misc/lib/shunit2

cp -r ../CUT/ "${rootfs_dir}/usr/local/"
cp -r ../docs "${rootfs_dir}/usr/local/CUT/"

print_info "creating bind mounts for chroot"
trap unmount_all EXIT
for mountpoint in $chroot_mounts; do
  mount --make-rslave --rbind "/${mountpoint}" "${rootfs_dir}/$mountpoint"
done

hostname="${args['hostname']}"

chroot_command="/opt/setup_rootfs_alpine.sh \
  '$DEBUG' \
  '$arch'" 

LC_ALL=C chroot $rootfs_dir /bin/sh -c "${chroot_command}"

sed -i  "s/-p host/-p internal/g" $rootfs_dir/usr/bin/gbb_flags_common.sh #make the GBB flags script not be stupid

trap - EXIT
unmount_all

print_info "rootfs has been created"
print_info "Final size: $(du -hd0 $rootfs_dir)"
