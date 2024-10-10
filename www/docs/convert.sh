#!/bin/env bash
green="<div class='green'>"
red="<div class='red'>"
purple="<div class='purple'>"
white="</div>"
bold="<div class='bold'>"
unbold="</div>"
italic="<div class='italic'>"
unitalic="</div>"
underline="<div class='underline'>"
nounderline="</div>"
section="<div class='section'>"
unsection="</div>"
title="<div class='title'>"
untitle="</div>"
subsection="<div class='subsection'>"
nosubsection="</div>"


replace () {
  pattern="${1}"
  replace="${2}"
  echo "${3}" | \
    while read -r line
  do
    echo "${line//${pattern}/${replace}}"
  done  
}

convert_doc () {
  doc_text=$(cat "../../docs/${1}")
  template=$(cat "./template.html")
  title=$(echo "${doc_text}"  | grep "\[TITLE\]" | sed -e "s/\[TITLE\]//g" -e "s/\[UNTITLE\]//g") #assume the title is one line
  desc=$(echo "${doc_text}"   | grep "\[DESC\]" | sed -e "s/\[DESC\]//g" -e "s/\[UNDESC\]//g") #ditto
  path="docs/${1}"
  template=$(replace '${path}'          "${path}"         "${template}")
  template=$(replace '${title}'         "${title}"        "${template}")
  template=$(replace '${desc}'          "${desc}"         "${template}")

  doc_text=$(replace "\[BOLD\]"         "${bold}"         "${doc_text}")
  doc_text=$(replace "\[UNBOLD\]"       "${unbold}"       "${doc_text}")
  doc_text=$(replace "\[ITALIC\]"       "${italic}"       "${doc_text}")
  doc_text=$(replace "\[UNITALIC\]"     "${unitalic}"     "${doc_text}")
  doc_text=$(replace "\[UNDERLINE\]"    "${underline}"    "${doc_text}")
  doc_text=$(replace "\[NOUNDERLINE\]"  "${nounderline}"  "${doc_text}")
 
  doc_text=$(replace "\[GREEN\]"        "${green}"        "${doc_text}")
  doc_text=$(replace "\[RED\]"          "${red}"          "${doc_text}")
  doc_text=$(replace "\[PURPLE\]"       "${purple}"       "${doc_text}")
  doc_text=$(replace "\[WHITE\]"        "${white}"        "${doc_text}")
  
  doc_text=$(replace "\[DESC\]"         "${desc}"         "${doc_text}")
  doc_text=$(replace "\[UNDESC\]"       "${undesc}"       "${doc_text}")
  doc_text=$(replace "\[SECTION\]"      "${section}"      "${doc_text}")
  doc_text=$(replace "\[UNSECTION\]"    "${unsection}"    "${doc_text}")
  doc_text=$(replace "\[SUBSECTION\]"   "${subsection}"   "${doc_text}")
  doc_text=$(replace "\[NOSUBSECTION\]" "${nosubsection}" "${doc_text}")
  
  doc_text=$(echo "${doc_text}" | sed -e "s/\(https\:\/\/[^ ]*\)/<a href='\1'>\1<\/a>/g")

  doc_text=$(echo "${doc_text}"         | tail -$(($(echo "${doc_text}" | wc -l) - 2))) # remove the title and desc, as they're in the template
  
  template=$(replace '${content}'     "${doc_text}"     "${template}")
  
  if [[ "${1}" =~ "/" ]]; then
    dir=$(echo $1 | sed "s/[^/]*\.txt//g")
    mkdir -p "render/$dir"
  fi
  echo "${template}" > "render/${1}.html"
}
rm -rf render
mkdir -p render
for i in $(find ../../docs/ | sed "s/\.\.\/\.\.\/docs\///g" | grep "\.txt") #just list the files
do
  echo $i
  convert_doc $i
done
