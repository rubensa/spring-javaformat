# syntax=docker/dockerfile:1.4
FROM nextail/ubuntu-tini-dev as base
# Architecture component of TARGETPLATFORM (platform of the build result)
ARG TARGETARCH
# Install libxrender1 and libxi6 (needed by the project)
RUN <<EOT
sudo apt-get update
echo "# Installing libxrender1..."
sudo apt-get -y install --no-install-recommends libxrender1 libxi6
sudo apt-get autoremove -y
sudo apt-get clean -y
sudo rm -rf /var/lib/apt/lists/*
EOT
# Install Node
ARG NODE_VERSION=19.6.0
RUN <<EOT
echo "Installing Node..."
export NVM_DIR=/opt/nvm
. /opt/nvm/nvm.sh
nvm install ${NODE_VERSION}
ln -s $(dirname $(dirname $(nvm which $NODE_VERSION))) /opt/nvm/versions/node/current
sudo ln -s /opt/nvm/versions/node/current/bin/node /usr/bin/node
cat $NVM_DIR/bash_completion >>  /home/${USER_NAME}/.bashrc
npm completion >> /home/${USER_NAME}/.bashrc
EOT
# Install Java
ARG JAVA_VERSION=8.0
RUN <<EOT
#!/bin/bash -l
echo "# Installing Java (needed by the project)..."
export SDKMAN_DIR=/opt/sdkman
. /opt/sdkman/bin/sdkman-init.sh
export JAVA_VERSION=${JAVA_VERSION}
export JAVA_INSTALL_VERSION=$(sdk list java | grep -o "${JAVA_VERSION}\.[0-9\.]*-tem" | head -1)
sdk install java $JAVA_INSTALL_VERSION || true
sudo mkdir -p /usr/lib/jvm
sudo ln -s /opt/sdkman/candidates/java/$JAVA_INSTALL_VERSION /usr/lib/jvm/$JAVA_VERSION
sdk default java $JAVA_INSTALL_VERSION
EOT
# Install Java
ARG JAVA_VERSION=11.0
RUN <<EOT
#!/bin/bash -l
echo "# Installing Java (needed by the project)..."
export SDKMAN_DIR=/opt/sdkman
. /opt/sdkman/bin/sdkman-init.sh
export JAVA_VERSION=${JAVA_VERSION}
export JAVA_INSTALL_VERSION=$(sdk list java | grep -o "${JAVA_VERSION}\.[0-9\.]*-tem" | head -1)
sdk install java $JAVA_INSTALL_VERSION || true
sudo mkdir -p /usr/lib/jvm
sudo ln -s /opt/sdkman/candidates/java/$JAVA_INSTALL_VERSION /usr/lib/jvm/$JAVA_VERSION
sdk default java $JAVA_INSTALL_VERSION
EOT
# Install Java
ARG JAVA_VERSION=17.0
RUN <<EOT
#!/bin/bash -l
echo "# Installing Java (needed by Java Language Server for RedHat extension)..."
export SDKMAN_DIR=/opt/sdkman
. /opt/sdkman/bin/sdkman-init.sh
export JAVA_VERSION=${JAVA_VERSION}
export JAVA_INSTALL_VERSION=$(sdk list java | grep -o "${JAVA_VERSION}\.[0-9\.]*-tem" | head -1)
printf '%s\n' n | sdk install java $JAVA_INSTALL_VERSION || true
sudo mkdir -p /usr/lib/jvm
sudo ln -s /opt/sdkman/candidates/java/$JAVA_INSTALL_VERSION /usr/lib/jvm/$JAVA_VERSION
EOT

FROM base
# Create maven repository directory so it is owned by the user
RUN mkdir -p /home/${USER_NAME}/.m2/repository
# Keep container running (for use in VSCode)
CMD [ "tail", "-f", "/dev/null" ]
