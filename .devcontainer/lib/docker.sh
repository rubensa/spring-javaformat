#!/usr/bin/env bash

# https://stackoverflow.com/a/58510109/3535783
[ -n "${DOCKER_LIB_IMPORTED}" ] && return; DOCKER_LIB_IMPORTED=0; # pragma once

_vscodeLibInit() {
  # Get current script path
  local SCRIPTPATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

  # Import common lib
  . ${SCRIPTPATH}/common.sh
}

_vscodeLibInit

dockerNetworkCreate() {
  logStart "Creating Docker network"

  local network_name=
  if [ $# -eq 0 ]; then
    returnError "Network name not specified."
  else
    network_name=$1
  fi

  docker network inspect ${network_name} >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    log "Network ${network_name} already exists"
  else
    docker network create ${network_name}
    [ $? -eq 0 ] || exit 1
    log "Network ${network_name} created"
  fi
  logEnd
}


dockerVolumeCreate() {
  logStart "Creating Docker volume"

  local volume_name=
  if [ $# -eq 0 ]; then
    returnError "Volume name not specified."
  else
    volume_name=$1
  fi

  docker volume inspect ${volume_name} >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    log "Volume ${volume_name} already exists"
  else
    docker volume create ${volume_name}
    [ $? -eq 0 ]  || exit 1
    log "Volume ${volume_name} created"
  fi
  logEnd
}
