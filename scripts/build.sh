#!/bin/bash

#build the bootloader image

. ./common.sh
. ./image_utils.sh
. ./shim_utils.sh

print_help() {
  echo "Usage: ./build.sh output_path shim_path rootfs_dir"
  echo "Valid named arguments (specify with 'key=value'):"
  echo "  quiet - Don't use progress indicators which may clog up log files."
  echo "  arch  - Set this to 'arm64' to specify that the shim is for an ARM chromebook."
}

assert_root
assert_deps "cpio binwalk pcregrep realpath cgpt mkfs.ext2 fdisk lz4"
assert_args "$3"
parse_args "$@"

output_path=$(realpath -m "${1}")
shim_path=$(realpath -m "${2}")
rootfs_dir=$(realpath -m "${3}")

quiet="${args['quiet']}"
arch="${args['arch']}"
name="${args['name']}"

print_info "reading the shim image"
kernel_img=/tmp/kernel.img
rm -rf $initramfs_dir $kernel_img
extract_initramfs_full $shim_path $kernel_img "$arch"

print_info "creating disk image"
#create a 35mb bootloader partition
create_image $output_path 35 

print_info "creating loop device for the image"
image_loop=$(create_loop ${output_path})

print_info "creating partitions on the disk image"
create_partitions $image_loop $kernel_img

print_info "copying data into the image"
echo $rootfs_dir
populate_partitions $image_loop $rootfs_dir "$quiet"
rm -rf $initramfs_dir $kernel_img

print_info "cleaning up loop devices"
losetup -d $image_loop

print_info "done"
