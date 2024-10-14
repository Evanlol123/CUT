#!/bin/sh

. usr/local/CUT/common.sh

pencilloop () {
  if ! [ $(get_wp_status) ]; then
    Echo "${green}${bold}WP already disabled; breaking${white}${unbold}"
    return
  fi
  echo "${red}${bold}DO NOT TOUCH YOUR FLASH CHIP WHILE DOING THIS"
  echo "DOING SO HAS A HIGH LIKELYHOOD OF DESTROYING YOUR CHIP, RENDEDRING YOUR SYSTEM UNUSABLE${white}"
  echo "Press ctrl+c at any time to cancel${unbold}"
  while :; do 
    if ! [ $(flashrom --wp-disable | grep -o "OK") ]then
			  echo "${green}${bold}Your WP was successfully disabled; you can now utilize the following payloads: ${white}${unbold}"
			  echo "- Legacy unenrollment"
			  echo "- Mr. Chromebox firmware utility script"
			  return
	  fi
	  echo "${red}WP disable FAILED${white}"
	  sleep 1
  done
}
