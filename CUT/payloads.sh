#!/bin/sh

. usr/local/CUT/common.sh

payloads () {
  local run=true
  while $run; do
    clear
    logo 
    echo "Payloads"
    sel=$(
    selectorLoop 1 \
      "Enrollment" \
      "Misc."
  )
    
    case $sel in
      1) enrollment;;
      2) misc;;
      *) run=false
    esac
  done
}

enrollment () {
  local run=true
  while $run; do 
    clear
    logo
    echo "${purple}Payloads - Enrollment"
    echo "${green}Payloads relating to both un and re-enrollment"
    sel=$(
      selectorLoop 1 \
        "Legacy unenrollment (<110)" \
        "Unfog (<114)" \
        "Cryptosmite(<119)" \
        "Caliginosity re-enrollment (unknown compatibility)" \
        "Pencilmod (no TI50)"
    )
    case $sel in
      1) usr/local/CUT/payloads/legacy.sh;;
      2) usr/local/CUT/payloads/unfog.sh;;
      3) usr/local/CUT/payloads/cryptsmite.sh;;
      4) usr/local/CUT/payloads/caliginosity.sh;;
      5) usr/local/CUT/payloads/pencil.sh;;
      *) run=false
    esac
  done
}

misc () {
  local run=true
  while $run; do
    clear
    logo
    echo "${purple}Payloads - Misc."
    echo "${Green}Payloads that don't fit under un/re-enrollment"
    sel=$(
      selectorLoop 1 \
        "Kernver rollback (0x000000)" \
        "Clobber-based update blocking"
    )
    case $sel in
      1) set_kver.sh 0x000000;;
      2) clobberblock.sh;;
      *) run=false
    esac
  done
}
