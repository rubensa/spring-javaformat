#!/bin/bash -i

# Import libs
. .devcontainer/lib/vscode.sh

# Install extensions if .devcontainer/extensions.json file exists
installExtensions .devcontainer/extensions.json || exit 1

# Install local extensions if .devcontainer/extensions.local.json file exists
installExtensions .devcontainer/extensions.local.json || exit 1

npm install -g yarn
npm install -g vsce
yarn config set "strict-ssl" false -g

logEnd
