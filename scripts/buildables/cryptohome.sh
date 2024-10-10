#!/bin/sh
if [ ! -d "${2}/cryptohome-repo" ]; then
  git clone https://chromium.googlesource.com/chromiumos/platform/cryptohome "${2}/cryptohome-repo"
fi
cd "${2}/cryptohome-repo"
make
