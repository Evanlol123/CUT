#!/bin/bash

 echo "NOTICE: KVS is for UNENROLLED CHROMEBOOKS ONLY!"
  echo "KVS payloads found and most of the code written by: kxtzownsu"
sleep 3
case "$(crossystem tpm_kernver)" in
  "0x00000000")
    kernver="0"
    echo "Current kernver: $kernver"
    ;;
  "0x00010001")
    kernver="1"
    echo "Current kernver: $kernver"
    ;;
  "0x00010002")
    kernver="2"
    echo "Current kernver: $kernver"
    ;;
  "0x00010003")
    kernver="3"
    echo "Current kernver: $kernver"
    ;;
  *)
    echo "invalid kernver wtf did u do"
    ;;
esac
echo "Please Enter Target kernver (0-3)"
      read -rep "> " kernver
      case $kernver in
        "0")
          echo "Setting kernver 0"
          initctl stop trunksd
          tpmc write 0x1008 02  4c 57 52 47  0 0 0 0  0 0 0  e8
          sleep 2
          echo "Finished writing kernver $kernver!"
          ;;
        "1")
          echo "Setting kernver 1"
          initctl stop trunksd
          tpmc write 0x1008 02  4c 57 52 47  1 0 1 0  0 0 0  55
    sleep 2
          echo "Finished writing kernver $kernver!"
          ;;
        "2")
          echo "Setting kernver 2"
          initctl stop trunksd
          tpmc write 0x1008 02  4c 57 52 47  2 0 1 0  0 0 0  33
    sleep 2
          echo "Finished writing kernver $kernver!"
          ;;
        "3")
          echo "Setting kernver 3"
          initctl stop trunksd
          tpmc write 0x1008 02  4c 57 52 47  3 0 1 0  0 0 0  EC
    sleep 2
          echo "Finished writing kernver $kernver!"
          ;;
        *)
          echo "That isnt a kernver dumbass" ;;
      esac
