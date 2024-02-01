#!/bin/bash -i

# Import common lib
. .devcontainer/lib/common.sh
# Import docker lib
. .devcontainer/lib/docker.sh

logStart "Initiallizing"

# Create user .ssh folder if it does not already exists
if [ ! -e ${HOME}/.ssh ]; then
  log "Creating ${HOME}/.ssh folder"
  mkdir -p ${HOME}/.ssh
fi

# Create user git config file if it does not already exists
if [ ! -e ${HOME}/.gitconfig ]; then
  log "Creating ${HOME}/.gitconfig file"
  touch ${HOME}/.gitconfig
fi

dockerVolumeCreate "vscode-server-extensions-cache"
dockerVolumeCreate "m2-repository-cache"

logEnd