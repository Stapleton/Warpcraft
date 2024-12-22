#!/bin/bash

# User Vars
MAXRAM="8G"
MINRAM="4G"
JVMARGS=""

# Program Vars Do Not Touch
REPO_URL="https://gitlab.com/Stapleton/smclt.git"
FABRIC_URL="https://meta.fabricmc.net/v2/versions/loader/1.20.1/0.15.11/1.0.1/server/jar"
JAVA_URL="https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jre/hotspot/normal/eclipse"
JAVA_DIR=".Java21"

StartServer() {
    echo '* Starting SMC Long Term Server'
    echo '****************************************'
    "$JAVA_DIR/bin/java" -Xms$MINRAM -Xmx$MAXRAM $JVMARGS -jar ./fabric.jar nogui
}

RemoveNonServerFriendlyMods() {
    echo '* Removing mods not friendly for servers'
    for f in $(cat ./NonServerFriendlyMods.txt) ; do 
        rm -v "./mods/$f"
    done
    echo '* Removed problematic mods'
    StartServer
}

InstallServer() {
    echo '* Installing SMC Long Term from Gitlab '
    echo '* * Cloning repo into temp folder'
    git clone $REPO_URL ./repo.tmp
    echo '* * Copying repo out of temp and into current folder'
    mv -f ./repo.tmp/* .
    mv ./repo.tmp/.git .
    echo '* * Deleting empty temp folder'
    rm -rf ./repo.tmp
    echo '* * Downloading Fabric Server Jar'
    wget $FABRIC_URL -O ./fabric.jar -q --show-progress
    echo '* * Downloading Java 21'
    wget $JAVA_URL -O ./java.zip -q --show-progress
    echo '* * Extracting Java 21'
    tar -xf ./java.zip
    mv ./jdk-*-jre ./$JAVA_DIR
    rm ./java.zip
    echo '* Server Installation Complete!'
    echo '****************************************'
    sleep 1
    RemoveNonServerFriendlyMods
}

UpdateServer() {
    echo '* Updating SMC Long Term from Gitlab'
    echo '* * Fetching changes from upstream'
    git fetch
    echo '* * Hard resetting local to match upstream'
    git reset --hard HEAD
    echo '* * Merging changes fetched from upstream'
    git merge origin/main
    echo '* Server Update Complete!'
    echo '****************************************'
    sleep 1
    RemoveNonServerFriendlyMods
}

GitRepoCheck() {
    if [ -d ".git/" ]; then
        echo '* Detected git repo. Updating Server!'
        UpdateServer
    else
        echo '* No .git folder was found. Installing Server!'
        InstallServer
    fi
}

GitCheck() {
    if [ -f $(command -v git) ]; then
        echo '* Git is installed, continuing execution...'
        GitRepoCheck
    else
        echo '* Git not found, please install Git!'
        exit 69
    fi
}

OSCheck() {
    if [ -d "/dev" ]; then
        echo '* OS is Linux, continuing execution...'
        GitCheck
    else
        echo '* OS is Windows, exiting ...'
        exit 69
    fi
}

echo '****************************************'
echo '* Launching SMC Long Term Server'
echo '* Checking for OS Type'
OSCheck
