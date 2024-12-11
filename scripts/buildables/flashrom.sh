#!/bin/env bash

if [ -f "${2}/flashrom-repo/flashrom" ]; then
    cp "${2}/flashrom-repo/flashrom" "${1}/usr/bin"
    exit
fi

og_pwd=$PWD
cd $2

# Clone and prepare the source
if ! [ -d "${2}/flashrom-repo" ]; then
    git clone -n https://chromium.googlesource.com/chromiumos/third_party/flashrom "${2}/flashrom-repo"
    cd "${2}/flashrom-repo"
    git checkout 24513f43e17a29731b13bfe7b2f46969c45b25e0
else
    cd "${2}/flashrom-repo"
    rm -rf build
    make clean
fi

# Apply null pointer fixes to cros_ec.c
sed -i 's/memcpy(s_cmd->data, outdata, outsize);/if (outdata != NULL && outsize > 0) { memcpy(s_cmd->data, outdata, outsize); }/' cros_ec.c
sed -i 's/memcpy(readarr + offset, buf, count);/if (buf != NULL && count > 0) { memcpy(readarr + offset, buf, count); }/' cros_ec.c
sed -i 's/memcpy(packet, &p, sizeof(p));/if (&p != NULL) { memcpy(packet, &p, sizeof(p)); }/' cros_ec.c
sed -i 's/memcpy(chip_vendor, chip_info.vendor, sizeof(chip_vendor));/if (chip_info.vendor != NULL) { memcpy(chip_vendor, chip_info.vendor, sizeof(chip_vendor)); }/' cros_ec.c

# Build the project
make strip CONFIG_STATIC=yes CONFIG_DEFAULT_PROGRAMMER_NAME=internal CFLAGS="-I/usr/include" LDFLAGS="-L/usr/lib" EXTRA_LIBS="-lz"
cp flashrom "${1}/usr/bin"
