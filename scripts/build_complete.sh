#!/bin/bash

. ./common.sh
. ./image_utils.sh

print_help() {
  echo "Usage: ./build_complete.sh board_names"
  echo "Valid named arguments (specify with 'key=value'):"
  echo "  compress     - Compress the final build into a zip file"
  echo "  quiet        - Don't use progress indicators which may clog up log files."
  echo "  data_dir     - The working directory for the scripts. This defaults to ../build"
  echo "  arch         - The CPU architecture to build the CUT image for. Set this to 'arm64' if you have an ARM Chromebook."
}

assert_root
assert_args "$1"
parse_args "$@"

base_dir="$(realpath -m  $(dirname "$0"))"
board="$1"

quiet="${args['quiet']}"
data_dir="${args['data_dir']-../build}"
arch="${args['arch']-amd64}"
compress_img="${args['compress']}"
build_dir="$(realpath -m ${args['build_dir']-../build})"

#a list of all arm board names
arm_boards="
  corsola hana jacuzzi kukui strongbad nyan-big kevin bob
  veyron-speedy veyron-jerry veyron-minnie scarlet elm
  kukui peach-pi peach-pit stumpy daisy-spring trogdor
"
#a list of shims that have a patch for the sh1mmer vulnerability
bad_boards="reef sand snappy pyro"
if grep -q "$board" <<< "$arm_boards" > /dev/null; then
  print_info "automatically detected arm64 device name"
  arch="arm64"
fi
if grep -q "$board" <<< "$bad_boards" > /dev/null; then
  print_error "Warning: you are attempting to build CUT for a board which has a shim that includes a fix for the sh1mmer vulnerability. The resulting image will not boot if you are enrolled."
  read -p "Press [enter] to continue "
fi

kernel_arch="$(uname -m)"
host_arch="unknown"
if [ "$kernel_arch" = "x86_64" ]; then
  host_arch="amd64"
elif [ "$kernel_arch" = "aarch64" ]; then
  host_arch="arm64"
fi

needed_deps="wget python3 unzip zip git debootstrap cpio binwalk pcregrep cgpt mkfs.ext4 mkfs.ext2 fdisk depmod findmnt lz4 pv"
if [ "$(check_deps "$needed_deps")" ]; then
  #install deps automatically on debian and ubuntu
  if [ -f "/etc/debian_version" ]; then
    print_title "attempting to install build deps"
    apt-get install wget python3 unzip zip debootstrap cpio binwalk pcregrep cgpt kmod pv lz4 -y
  fi
  assert_deps "$needed_deps"
fi

#install qemu-user-static on debian if needed
if [ "$arch" != "$host_arch" ]; then
  if [ -f "/etc/debian_version" ]; then
    if ! dpkg --get-selections | grep -v deinstall | grep "qemu-user-static\|box64\|fex-emu" > /dev/null; then
      print_info "automatically installing qemu-user-static because we are building for a different architecture"
      apt-get install qemu-user-static binfmt-support -y
    fi
  else 
    print_error "Warning: You are building an image for a different CPU architecture. It may fail if you do not have qemu-user-static installed."
    sleep 1
  fi
fi

cleanup_path=""
sigint_handler() {
  if [ $cleanup_path ]; then
    rm -rf $cleanup_path
  fi
  exit 1
}
trap sigint_handler SIGINT

shim_url="https://dl.darkn.bio/api/raw/?path=/SH1mmer/$board.zip"
boards_url="https://chromiumdash.appspot.com/cros/fetch_serving_builds?deviceCategory=ChromeOS"

data_dir="$(realpath -m "$data_dir")"

shim_bin="$data_dir/shim_$board.bin"
shim_zip="$data_dir/shim_$board.zip"
mkdir -p "$data_dir"

download_and_unzip() {
  local url="$1"
  local zip_path="$2"
  local bin_path="$3"
  if [ ! -f "$bin_path" ]; then
    if [ ! "$quiet" ]; then
      wget -q --show-progress $url -O $zip_path -c
    else
      wget -q $url -O $zip_path -c
    fi
  fi

  if [ ! -f "$bin_path" ]; then
    cleanup_path="$bin_path"
    print_info "extracting $zip_path"
    local total_bytes="$(unzip -lq $zip_path | tail -1 | xargs | cut -d' ' -f1)"
    if [ ! "$quiet" ]; then
      unzip -p $zip_path | pv -s $total_bytes > $bin_path
    else
      unzip -p $zip_path > $bin_path
    fi
    rm -rf $zip_path
    cleanup_path=""
  fi
}

retry_cmd() {
  local cmd="$@"
  for i in 1 2 3 4 5; do
    $cmd && break
  done
}

print_title "downloading shim image"
download_and_unzip $shim_url $shim_zip $shim_bin

print_title "building Alpine miniroot"
if [ ! "$rootfs_dir" ]; then
  rootfs_dir="$(realpath -m $data_dir/rootfs_$board)"
  if [ "$(findmnt -T "$rootfs_dir/dev")" ]; then
    sudo umount -l $rootfs_dir/* 2>/dev/null || true
  fi
  rm -rf $rootfs_dir
  mkdir -p $rootfs_dir
  
  ./build_rootfs.sh $rootfs_dir \
    "${build_dir}" \
    hostname=CUT-$board \
    arch=$arch 
fi

print_title "building final disk image"
final_image="$data_dir/CUT-$board.bin"
rm -rf $final_image
echo $rootfs_dir
retry_cmd ./build.sh $final_image $shim_bin $rootfs_dir "quiet=$quiet" "arch=$arch" 
print_info "build complete! the final disk image is located at $final_image"

print_title "cleaning up"
clean_loops

print_info "Final image size: $(du -smh $final_image)"
if [ "$compress_img" ]; then
  image_zip="$data_dir/CUT-$board.xz"
  print_title "compressing disk image into a zip file"
  time xz -z9ce $final_image > $image_zip
  print_info "finished compressing the disk file"
  print_info "the finished zip file can be found at $image_zip" 
  print_info "Final zip size: $(du -smh $image_zip)"
fi
