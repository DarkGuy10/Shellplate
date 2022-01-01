#!/usr/bin/env bash

# ===========================================================
# Shellplate boilerplate v1.0
# Written by: @DarkGuy10 (https://github.com/DarkGuy10)
# Shellplate Repo: https://github.com/DarkGuy10/Shellplate
# ===========================================================

script_name=""
script_author=""
script_version=""
script_repository=""
script_description=""

centre() {
  length=${#1}
  if [[ $length -lt 80 ]]; then
    printf "%*s\n" $((($length+80)/2)) "$1"
  else
    echo "$1" | fold -w 80
  fi
}

header(){
  tput bold; centre "[ $1 ]"; tput sgr0
}

check_requirements() {
  printf "=================================\n"
  printf "===   CHECKING REQUIREMENTS   ===\n"
  printf "=================================\n"
  all_dependencies_met="true"
  count=`grep "" requirements.txt -c`
  for (( i = 1; i <= $count; i++ )); do
    req=`grep "" requirements.txt -m "$i" | tail -1`
    sleep 0.3
    printf "\t$req"
    if [ ! -z `command -v $req` ]; then
      printf "\tOK\n"
    else
      printf "\tUNMET\n"
      all_dependencies_met=""
    fi
  done
  if [[ -z "$all_dependencies_met" ]]; then
    printf "Some script dependencies are unmet\nManually install them and rerun the script\n"
    exit
  fi
  printf "All dependencies met!\n"
  sleep 1
}

load_script_variables() {
  script_name=`jq -r '.name' < project.json`
  script_author=`jq -r '.author' < project.json`
  script_version=`jq -r '.version' < project.json`
  script_repository=`jq -r '.repository' < project.json`
  script_description=`jq -r '.description' < project.json`
}

pretty_banner() {
  clear
  cat ascii_art.txt
  printf '=%.0s' {1..80}
  printf "\n"
  tput bold; centre "$script_description"; tput sgr0
  centre "Author: @$script_author | Git repo: $script_repository"
  centre "Script Version: v$script_version"
  printf '=%.0s' {1..80}
  printf "\n"
}

main(){
  pretty_banner
  # _________________________
  # < Place your code here... >
  #  -------------------------
  #         \   ^__^
  #          \  (oo)\_______
  #             (__)\       )\/\
  #                 ||----w |
  #                 ||     ||
  #
}

check_requirements
load_script_variables
main
