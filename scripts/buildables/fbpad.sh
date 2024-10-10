#!/bin/sh
og_pwd="${PWD}"
if [ ! -d "${2}/fbpad" ]; then
  git clone https://github.com/aligrudi/fbpad "${2}/fbpad"
  cd "${2}/fbpad"
  git apply "${og_pwd}/buildables/patches/fbpad.patch"
fi
if [ ! -d "${2}/fbpad-mkfn" ]; then
  git clone https://repo.or.cz/fbpad_mkfn.git "${2}/fbpad-mkfn"
fi
if [ ! -f "${2}/firacode.zip" ]; then
  curl -L "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o "${2}/firacode.zip" 
fi

mkdir -p "${2}/firacode"
mkdir -p "${1}/usr/local/fonts/"

cd "${2}/firacode"
unzip "${2}/firacode.zip"

cd "${2}/fbpad"
STATIC=1 LD_FLAGS=-static make 
cp fbpad "${1}/usr/bin/fbpad"

cd "${2}/fbpad-mkfn"
make

SZ="9h100v100r-3"
./mkfn_ft -h 20 -w 8 "${2}/firacode/ttf/FiraCode-Regular.ttf:$SZ" > "${1}/usr/local/fonts/firacode.tf"
./mkfn_ft -h 20 -w 8 "${2}/firacode/ttf/FiraCode-Bold.ttf:$SZ" > "${1}/usr/local/fonts/firacode-bold.tf"
./mkfn_ft -h 20 -w 8 "${2}/firacode/ttf/FiraCode-Retina.ttf:$SZ" > "${1}/usr/local/fonts/firacode-italic.tf"
