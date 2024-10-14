#!/bin/sh

. usr/local/CUT/common.sh

connect_wireless () {
  # get wireless interface
  wlan=$(ls /sys/class/net | grep -o "wlp[^ ]*")
  if [ $wlan ]; then
    echo "Connecting with device ${wlan}"
    read -p "Enter your wireless SSID: " ssid
    read -p "Enter your wireless password (echo is ON): " passwd
    wpa_supplicant -Dnl80211 -i$wlan -c < $(wpa_passphrase "${ssid}" "${passwd}") -B
    udhcpd
  else
    echo "${red} No wireless device found; your board doesn't support this function ${white}"
  fi
}
