#!/bin/env bash
# Adapted and fixed using the working build script
# Original source: https://github.com/MercuryWorkshop/sh1mmer/blob/beautifulworld/wax/lib/buildables/flashrom/build.sh

set -e

if [ -f "${2}/flashrom-repo/flashrom" ]; then
	cp "${2}/flashrom-repo/flashrom" "${1}/usr/bin"
	exit
fi

og_pwd=$PWD
cd $2

CROSS=
STRIP=strip
CROSSFILE=
if [ -z "$3" ]; then
	CROSS=("CC=${1}-gcc" "STRIP=${1}-strip" "AR=${1}-ar" "RANLIB=${1}-ranlib" "PKG_CONFIG=${1}-pkg-config")
	STRIP="${1}-strip"
	CROSSFILE="$(mktemp)"
	(
	echo "[binaries]"
	echo "c = '${1}-gcc'"
	echo "cpp = '${1}-g++'"
	echo "ar = '${1}-ar'"
	echo "strip = '${1}-strip'"
	echo "pkgconfig = '${1}-pkg-config'"
	echo ""
	echo "[host_machine]"
	echo "system = '$(echo "$1" | cut -d- -f2)'"
	echo "cpu_family = '$(echo "$1" | cut -d- -f1)'"
	echo "cpu = '$(echo "$1" | cut -d- -f1)'"
	echo "endian = 'little'"
	) >"$CROSSFILE"
	CROSSFILE="--cross-file=$CROSSFILE"
fi

rm -rf lib
mkdir lib
LIBDIR="$(realpath lib)"

# Build pciutils
if ! [ -d "${2}/pciutils" ]; then
	git clone https://github.com/pciutils/pciutils "${2}/pciutils"
	cd "${2}/pciutils"
	git checkout v3.11.1
else
	cd "${2}/pciutils"
	make clean
fi

if [ -z "$1" ]; then
	make install-lib DESTDIR="$LIBDIR" PREFIX=
else
	make install-lib DESTDIR="$LIBDIR" PREFIX= CROSS_COMPILE="$1"- HOST="$1"
fi
cd ..

# Build systemd to get libudev.a
if ! [ -d "${2}/systemd" ]; then
	git clone -n https://github.com/systemd/systemd "${2}/systemd"
	cd "${2}/systemd"
	git checkout v255
else
	cd "${2}/systemd"
	rm -rf build
fi

meson setup -Dbuildtype=release -Dstatic-libudev=true -Dprefix=/ -Dc_args="-Wno-error=format-overflow" "$CROSSFILE" build
ninja -C build libudev.a devel
cp build/libudev.a "$LIBDIR/lib"
mkdir -p "$LIBDIR/lib/pkgconfig"
cp build/src/libudev/libudev.pc "$LIBDIR/lib/pkgconfig"
[ ! -f "$CROSSFILE" ] || rm "$CROSSFILE"
cd ..

# Build flashrom
if ! [ -d "${2}/flashrom-repo" ]; then
	git clone -n https://chromium.googlesource.com/chromiumos/third_party/flashrom "${2}/flashrom-repo"
	cd "${2}/flashrom-repo"
	git checkout 24513f43e17a29731b13bfe7b2f46969c45b25e0
	git apply "$og_pwd/buildables/patches/flashrom.patch"
else
	cd "${2}/flashrom-repo"
	rm -rf build
	make clean
fi

export PKG_CONFIG_PATH="$LIBDIR/lib/pkgconfig"

make strip CONFIG_STATIC=yes CONFIG_DEFAULT_PROGRAMMER_NAME=internal \
  CFLAGS="-I$LIBDIR/include" \
  LDFLAGS="-L$LIBDIR/lib" \
  EXTRA_LIBS="-lcap -lz" "${CROSS[@]:-}"
cp flashrom "${1}/usr/bin"
