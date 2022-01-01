#!/usr/bin/env bash

# ============================================
# This script is kind of an interactive wizard
# I'll add arguements and flags to skip this
# step in later versions
# Happy scripting!
# ============================================

script_name=""
script_author=""
script_version=""
script_repository=""
script_description=""
available_fonts=(graffiti)

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
  figlet -f fonts/graffiti -k -c "$script_name"
  printf '=%.0s' {1..80}
  printf "\n"
  tput bold; centre "$script_description"; tput sgr0
  centre "Author: @$script_author | Git repo: $script_repository"
  centre "Script Version: v$script_version"
  printf '=%.0s' {1..80}
  printf "\n"
}

updater(){
  pretty_banner
  header "SCRIPT UPDATER"
  fetch=`curl -s https://raw.githubusercontent.com/DarkGuy10/Shellplate/main/project.json || echo "error"`
  if [[ "$fetch" == "error" || "$fetch" == "404: Not Found" ]]; then
    printf "[ * ] An error occurred while checking for updates. Skipping.\n"
    sleep 3
    return
  fi

  latest_script_version=$("$fetch" | jq -r '.version')
  if [[ "$script_version" != "$latest_script_version" ]]; then
    printf "[ + ] A new version is available! "
    tput bold; printf "(v$latest_script_version)\n"; tput sgr0
  fi
  sleep 3
}

main(){
  pretty_banner
  header "SHELLPLATE WIZARD"
  create_script_name=""
  create_script_author=""
  create_script_font=""

  while [[ -z "$create_script_name" ]]; do
    printf "[ ? ] Project Name (required): "
    read create_script_name
  done

  printf "[ ? ] Description (default=\"\"): "
  read create_script_description

  while [[ -z "$create_script_author" ]]; do
    printf "[ ? ] Author (required): "
    read create_script_author
  done

  printf "[ ? ] Version (default=1.0): "
  read create_script_version
  if [[ -z "$create_script_version" ]]; then
    create_script_version="1.0"
  fi

  while [[ ! " ${available_fonts[*]} " =~ " ${create_script_font} " ]]; do
    printf "[ ? ] ASCII art font (default=graffiti): "
    read create_script_font
    if [[ -z "$create_script_font" ]]; then
      create_script_font=graffiti
      break
    fi
  done

  printf "[ ? ] Default git branch (default=main): "
  read default_branch

  printf "[ ? ] Git repo: "
  read create_script_repository
  printf "\n"

  create_script_json="{\"name\": \"$create_script_name\", \"author\": \"$create_script_author\", \"version\": \"$create_script_version\", \"repository\": \"$create_script_repository\", \"description\": \"$create_script_description\"}"
  printf "A project with the following details will be constructed in /out directory\n"
  echo  "$create_script_json"| jq .
  printf "\n[ ? ] Confirm project creation (Y/n): "
  read confirm
  if [[ "${confirm:0:1}" == "N" || "${confirm:0:1}" == "n" ]]; then
    printf "[ - ] user abort\n"
    exit
  fi

  if [[ ! -d out/ ]]; then
    mkdir out
  fi
  mkdir out/"$create_script_name"
  cd out/"$create_script_name"

  if [[ ! -z "$default_branch" ]]; then
    git init -q -b "$default_branch"
  else
    git init -q -b main
  fi

  echo "$create_script_json" | jq . > project.json
  echo -e "# $create_script_name\n $create_script_description" > README.md
  figlet -f ../../fonts/"$create_script_font" -c "$create_script_name" > ascii_art.txt
  echo -e "jq\nfmt\ntput" > requirements.txt
  cat ../../template/boilerplate.sh > "$create_script_name.sh"

  printf "[ + ] New project created in \`out/$create_script_name/\`\n"
  printf "[ > ] Exitting $script_name@$script_version\n"
}

check_requirements
load_script_variables
#updater
main
