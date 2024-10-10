#!/bin/sh
red=$(printf "\x1B[31m")
green=$(printf "\x1B[32m")
purple=$(printf "\x1B[35m")
white=$(printf "\x1B[37m")
bold=$(printf "\x1B[1m")
unbold=$(printf "\x1B[22m")
italic=$(printf "\x1B[3m")
unitalic=$(printf "\x1B[23m")
underline=$(printf "\x1B[4m")
nounderline=$(printf "\x1B[24m")

logo () {
  echo "$purple"
  cat << EOF
             ______ __  __ ______
|========/  / ____// / / //_  __/  /=====| 
|=======/  / /    / / / /  / /    /======|
|======/  / /___ / /_/ /  / /    /=======|
|=====/   \____/ \____/  /_/    /========|

------------------------------------------
EOF
  echo "$white $bold"
  echo "     ChromeOS Unenrollment Toolkit$unbold"
  echo "Arrow keys to navigate, Enter to select, b to go back"
}

get_wp_status () {
  status=$(flashrom --wp-status 2>&1 | grep -o "Protection mode: hardware")
  if [ "$status" = "Protection mode: hardware" ]; then
    echo 1
  else
    echo 0
  fi
}

check_wp_status () {
  if [ get_wp_status ]; then 
    echo "WP enabled; aborting!"
    return 1
  else
    return 0
  fi
}

check_fwmp_status () { #can't wait to implement this 🫠
  test
}

status () {
  echo "${bold}$1${unbold}"
}

print_doc () {
  doc=$1
  doc_text=$(cat "usr/local/CUT/docs/${doc}.txt")
  doc_text=$(echo "${doc_text}" | sed "s/\[GREEN\]/${green}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[RED\]/${red}]/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[PURPLE\]/${purple}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[WHITE\]/${white}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[BOLD\]/${bold}]/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[UNBOLD\]/${unbold}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[ITALIC\]/${italic}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[UNITALIC\]/${unitalic}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[UNDERLINE\]/${underline}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[NOUNDERLINE\]/${nounderline}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[SECTION\]/${bold}${underline}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[UNSECTION\]/${unbold}${nounderline}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[TITLE\]/# ${bold}${underline}${green}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[UNTITLE\]/${unbold}${nounderline}${white}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[DESC\]/${bold}${underline}${green}/g")
  doc_text=$(echo "${doc_text}" | sed "s/\[UNDESC\]/${unbold}${nounderline}${ungreen}/g")
  clear
  echo "${doc_text}" | less
}

#Below is for the TUI, stolen from the sh1mmer_payload.sh script

readinput() {
	local mode
	read -rsn1 mode

	case "$mode" in
		'') read -rsn2 mode ;;
		'b') echo kB ;;
		'') echo kE ;;
		*) echo "$mode" ;;
	esac

	case "$mode" in
		'[A') echo kU ;;
		'[B') echo kD ;;
		'[D') echo kL ;;
		'[C') echo kR ;;
	esac
}

function setup() {
	stty -echo # turn off showing of input
	printf "\033[?25l" # turn off cursor so that it doesn't make holes in the image
	printf "\033[2J\033[H" # clear screen
	sleep 0.1
}

function cleanup() {
	printf "\033[2J\033[H" # clear screen
	printf "\033[?25h" # turn on cursor
	stty echo
}

function movecursor_generic() {
	printf "\033[$((2+$1));1H"
}

selectorLoop() {
	local selected idx input
	selected=1
	while :; do
		idx=0
		for opt in "$@"; do
		  if [ $idx -eq 0 ]; then
		    idx=1
		    continue
		  fi
			movecursor_generic $(($idx+$(logo | wc -l)+$1)) >&2
			if [ $idx -eq $selected ]; then
				printf "\033[0;36m" >&2
				echo -n "--> $opt" >&2
			else
				printf "\033[0m" >&2
				echo -n "    $opt" >&2
			fi
			printf "\033[0m" >&2
			idx=$(($idx+1))
		done
		input=$(readinput)
		case "$input" in
		'kB') return 1 ;; # doesn't seem to work?
		'kE') echo $selected; return ;;
		'kU')
		  selected=$(($selected-1))	
			if [ $selected -lt 1 ]; then selected=$(($# - 1)); fi
			;;
		'kD')
			selected=$(($selected+1))
			if [ $selected -ge $# ]; then selected=1; fi
			;;
		esac
	done
	cleanup
}
