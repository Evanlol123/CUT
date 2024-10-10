#!/bin/sh

. usr/local/CUT/common.sh

docs () {
  run=true
  while $run
  do
    clear
    logo
    echo "${purple}Documentation${white}"
    echo "${green}Collection of documentation of systems and guides on how to use the various payloads included in CUT.${white}"
    sel=$(
      selectorLoop 1 \
        "ChromeOS systems" \
        "Payloads" \
        "Utilities" 
    )
    case $sel in
      1) systems;;
      2) payloads;;
      3) utils;;
      *) run=false
    esac
  done
}

systems () {
  run=true
  while $run
  do
    clear
    logo
    echo "${purple}Documentation - ChromeOS systems${white}"
    echo "${green}Documentation on the various systems utilized in ChromeOS${white}"
    sel=$(
        selectorLoop 1 \
          "Basic terms and systems" \
          "FWMP" \
          "Kernel Versions" \
          "Update system" \
          "(Enc)stateful" \
          "Titan-C vs CR50 vs TI50" \
          "AP" \
          "VPD"
    )
    case $sel in
      1) print_doc "systems/terminology" ;;
      3) print_doc "systems/kernver" ;;
      '') run=false ;;
      *) echo "Sorry, I haven't written this docpage yet"
    esac
  done
}
