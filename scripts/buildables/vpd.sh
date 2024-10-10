#!/bin/sh
#Fuck Google for making me use GN for this
#set +x
#if [ ! -d gn ]; then
#  git clone https://gn.googlesource.com/gn
#fi

#if [ ! -d gn/out ]; then
#  cd gn
#  python build/gen.py # --allow-warning if you want to build with warnings.
#  ninja -C out
#  cd ..
#fi
if [ -f "${2}/vpd/vpd" ]; then
  cp "${2}/vpd/vpd" "${1}/usr/bin"
  exit
fi

if [ ! -d "${2}/vpd" ]; then
  git clone https://chromium.googlesource.com/chromiumos/platform/vpd "${2}/vpd"
  cd "${2}/vpd"
  git checkout b2f3b1fe88db8dcc2777972ad882a370d52f97a7
fi
cd "${2}/vpd"
make 
cp vpd "${1}/usr/bin"
