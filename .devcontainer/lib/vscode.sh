#!/usr/bin/env bash

# https://stackoverflow.com/a/58510109/3535783
[ -n "${VSCODE_LIB_IMPORTED}" ] && return; VSCODE_LIB_IMPORTED=0; # pragma once

_vscodeLibInit() {
  # Get current script path
  local SCRIPTPATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

  # Import common lib
  . ${SCRIPTPATH}/common.sh
}

_vscodeLibInit

#######################
## GIT HOOKS SUPPORT ##
#######################

setUpGitHooks() {
  # Get current script path
  local SCRIPTPATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

  logStart "Setting up git hooks"
  for file in ${SCRIPTPATH}/../git-hooks/*; do
    filename=${file##*/}
    ln -s -f ../../.devcontainer/git-hooks/$filename ${SCRIPTPATH}/../../.git/hooks/$filename
  done
  logEnd
}

###############################
## VSCODE EXTENSIONS SUPPORT ##
###############################

installExtensions() {
  logStart "Installing extensions"

  local extensions_file=
  if [ $# -eq 0 ]; then
    returnError "Extensions file not specified."
  else
    extensions_file=$1
  fi

  # Install extensions if file exists
  if  [ -e ${extensions_file} ]; then

    if [ -f ~/.vscode-server/bin/*/bin/code-server ]; then
      extensions=( $(sed '/^[[:blank:]]*#/d;s/\/\/.*//' ${extensions_file} | jq -r -c '.extensions[]') )
      ~/.vscode-server/bin/*/bin/code-server ${extensions[@]/#/--install-extension }
    elif [ -f ~/.vscode-server-insiders/bin/*/bin/code-server-insiders ]; then
      extensions=( $(sed '/^[[:blank:]]*#/d;s/\/\/.*//' ${extensions_file} | jq -r -c '.extensions[]') )
      ~/.vscode-server-insiders/bin/*/bin/code-server-insiders ${extensions[@]/#/--install-extension }
    else
      logError "Could not find code-server command"
    fi
  else
    logWarn "Could not find ${extensions_file} file"
  fi

  logEnd
}

##########################################
## VSCODE REPOSITORY CONTAINERS SUPPORT ##
##########################################

enableRepositoryContainersConfig() {
  logStart "Enabling repository containers config"

  local project_name=
  if [ $# -eq 0 ]; then
    returnError "Project name not specified."
  else
    project_name=$1
  fi

  # Get current script path
  local SCRIPTPATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  local DEV_CONTAINER_FOLDER=$( cd -- "$( dirname -- "${SCRIPTPATH}" )" &> /dev/null && pwd )

  # Create .env file if it does not already exists
  if [ ! -e ${DEV_CONTAINER_FOLDER}/.env ]; then
    log "Creating ${DEV_CONTAINER_FOLDER}/.env file"
    touch ${DEV_CONTAINER_FOLDER}/.env
  fi

  # Set environment variables in .env
  loadDotEnv ${DEV_CONTAINER_FOLDER}/.env || exit 1

  # Set repositoryConfigurationPath environment variable if not already set
  if ! envVarSetted repositoryConfigurationPath; then
    log "Setting repositoryConfigurationPath into ${DEV_CONTAINER_FOLDER}/.env file"
    printf "\nrepositoryConfigurationPath=${DEV_CONTAINER_FOLDER}\n" >> ${DEV_CONTAINER_FOLDER}/.env
  fi

  # Create .env if it does not already exists
  if [ ! -e .env ]; then
    log "Creating .env file"
    touch .env
  fi
  # Set environment variables in .env
  loadDotEnv .env || exit 1
  # Set COMPOSE_PROJECT_NAME environment variable if not already set
  if ! envVarSetted COMPOSE_PROJECT_NAME; then
    log "Setting COMPOSE_PROJECT_NAME into .env file"
    printf "\nCOMPOSE_PROJECT_NAME=${project_name}\n" >> .env
  fi

  logEnd
}

###########################
## VSCODE SDKMAN SUPPORT ##
###########################

# Syncronize SDKMan candidates cache
syncSDKManCandidatesCache() {
  # If both folders exist
  if [ -d /opt/sdkman/candidates ] && [ -d /home/user/.sdkman/candidates ]; then
    logStart "Syncronizing SDKMan candidates cache"
    # For each language in any of the two folders
    for language in $(find /opt/sdkman/candidates /home/user/.sdkman/candidates -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | uniq); do
      subFoldersSync /opt/sdkman/candidates/$language /home/user/.sdkman/candidates/$language
    done
    logEnd
  fi
}

# Syncronize LTeX library cache for valentjn.vscode-ltex VSCode extension
syncLTeXLibraryCache() {
  # Get valentjn.vscode-ltex VSCode extension folder path
  vscode_ltex_dir=$(find /home/user/.vscode-server/extensions/ -maxdepth 1 -name valentjn.vscode-ltex-\* -type d -print 2>/dev/null | head -n1)
  if [ -d "$vscode_ltex_dir" ] && [ -d /home/user/.ltex ]; then
    logStart "Syncronizing LTeX library cache"
    subFoldersSync "$vscode_ltex_dir/lib" /home/user/.ltex/lib
    logEnd
  fi
  # Get valentjn.vscode-ltex VSCode extension folder path (vscode insiders)
  vscode_ltex_dir=$(find /home/user/.vscode-server-insiders/extensions/ -maxdepth 1 -name valentjn.vscode-ltex-\* -type d -print 2>/dev/null | head -n1)
  if [ -d "$vscode_ltex_dir" ] && [ -d /home/user/.ltex ]; then
    logStart "Syncronizing LTeX library cache"
    subFoldersSync "$vscode_ltex_dir/lib" /home/user/.ltex/lib
    logEnd
  fi
}
