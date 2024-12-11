#!/bin/env bash
# Edited from source: https://github.com/MercuryWorkshop/sh1mmer/blob/beautifulworld/wax/lib/buildables/flashrom/build.sh

if [ -f "${2}/flashrom-repo/flashrom" ]; then
	cp "${2}/flashrom-repo/flashrom" "${1}/usr/bin"
	exit
fi

og_pwd=$PWD
cd "$2"

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
	echo "pkg-config = '${1}-pkg-config'"
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

if ! [ -d "${2}/pciutils" ]; then
	git clone https://github.com/pciutils/pciutils "${2}/pciutils"
	cd "${2}/pciutils"
	git checkout v3.11.1
else
	cd "${2}/pciutils"
	make clean
fi

make install-lib DESTDIR="$LIBDIR" PREFIX=

if ! [ -d "${2}/flashrom-repo" ]; then
	git clone -n https://chromium.googlesource.com/chromiumos/third_party/flashrom "${2}/flashrom-repo"
	cd "${2}/flashrom-repo"
	git checkout 24513f43e17a29731b13bfe7b2f46969c45b25e0
else
	cd "${2}/flashrom-repo"
	rm -rf build
	make clean
fi

# fix memcpy null warnings
patch -p1 <<'EOF'
--- a/cros_ec.c
+++ b/cros_ec.c
@@ -227,7 +227,7 @@
 {
 	struct cros_ec_command *s_cmd = cmd;
 
-	memcpy(s_cmd->data, outdata, outsize);
+	if (outdata) memcpy(s_cmd->data, outdata, outsize);
 
 	return 0;
 }
@@ -763,7 +763,7 @@
 	{
 		int offset = 0;
 		while (count > 0) {
-			memcpy(readarr + offset, buf, count);
+			if (buf) memcpy(readarr + offset, buf, count);
 			offset += count;
 		}
 	}
@@ -928,7 +928,7 @@
 		return -1;
 
 	/* Write packet header */
-	memcpy(packet, &p, sizeof(p));
+	if (&p) memcpy(packet, &p, sizeof(p));
 
 	return 0;
 }
@@ -1081,7 +1081,7 @@
 		return -1;
 
 	/* Read chip info */
-	memcpy(chip_vendor, chip_info.vendor, sizeof(chip_vendor));
+	if (chip_info.vendor) memcpy(chip_vendor, chip_info.vendor, sizeof(chip_vendor));
 
 	return 0;
 }
EOF

export PKG_CONFIG_PATH="$LIBDIR/lib/pkgconfig"

make strip CONFIG_STATIC=yes CONFIG_DEFAULT_PROGRAMMER_NAME=internal CFLAGS="-I$LIBDIR/include" LDFLAGS="-L$LIBDIR/lib" EXTRA_LIBS="-lz"

if [ -f "flashrom" ]; then
	cp flashrom "${1}/usr/bin"
else
	echo "Error: flashrom binary not built."
	exit 1
fi
