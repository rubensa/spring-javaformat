#!/usr/bin/env bash

# https://stackoverflow.com/a/58510109/3535783
[ -n "${COMMON_LIB_IMPORTED}" ] && return; COMMON_LIB_IMPORTED=0; # pragma once

##################
## LOG MESSAGES ##
##################

LOG_INDENT=""

log() {
  printf "%s%s\n" "${LOG_INDENT}" "$*"
}

logWarn() {
  log "[Warn] $*"
}

logError() {
  echo "[Error] $*" >>/dev/stderr
}

logStart() {
  log "[*] $*"
  LOG_INDENT="${LOG_INDENT}.."
}

logEnd() {
  LOG_INDENT="${LOG_INDENT%??}"
  log "[*] Done."
}

returnError() {
  logError "$*"
  return 1
}

failError() {
  logError "$*"
  exit 1
}

###################################
## ENVIRONMENT VARIABLES SUPPORT ##
###################################

# https://stackoverflow.com/a/60652702/3535783
envVarSetted() {
  local env_var=
  if [ $# -eq 0 ]; then
    returnError "Environment variable not specified."
  else
    env_var=$(declare -p "$1" 2>/dev/null)
  fi
  if [[ !  $env_var =~ ^declare\ -x ]]; then
    returnError "$1 environment variable not set."
  fi
}

envVarsSetted() {
  local env_var=
  for env_var in "$@"; do
    envVarSetted "$env_var" || return 1
  done
}

##################
## FILE SUPPORT ##
##################

fileExists() {
  local file=
  if [ $# -eq 0 ]; then
    returnError "File not specified."
  else
    file=$1
  fi
  if [ ! -f "$file" ]; then
    returnError "$file file does not exists."
  fi
}

####################
## FOLDER SUPPORT ##
####################

# Sync folder content (any file or folder)
folderSync () {
  if [ "$#" -lt 2 ]; then
    returnError "Folders not specified."
  fi
  logStart "Syncing $1 and $2"
  if [ -d $1 ] || [ -d $2 ]; then
    [ -d $1 ] || mkdir -p $1
    [ -d $2 ] || mkdir -p $2

    # copy both ways (aka sync)
    cp -r -n $1/* $2/ 2>/dev/null
    cp -r -n $2/* $1/ 2>/dev/null
  fi
  logEnd
}

# Sync subfolders only
subFoldersSync () {
  if [ "$#" -lt 2 ]; then
    returnError "Folders not specified."
  fi
  logStart "Syncing $1 and $2"
  if [ -d $1 ] || [ -d $2 ]; then
    [ -d $1 ] || mkdir -p $1
    [ -d $2 ] || mkdir -p $2

    # for each subfolder (not symbolic links) in any of the two folders
    for sub_folder in $(find $1 $2 -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | uniq); do
      folderSync $1/$sub_folder $2/$sub_folder
    done
  fi
  logEnd
}

#####################
## DOT ENV SUPPORT ##
#####################

loadDotEnv() {
  local dot_env_file=
  if [ $# -eq 0 ]; then
    returnError "Dot env file not specified."
  else
    dot_env_file=$1
  fi

  fileExists $dot_env_file || return 1

  set -a # set -o allexport
  . $dot_env_file
  set +a # set +o allexport
}
