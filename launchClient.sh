#!/bin/bash
REPO_URL="https://gitlab.com/Stapleton/smclt.git"

InstallPack() {
    echo '* Installing SMC Long Term from Gitlab '
    echo '* * Cloning repo into temp folder'
    git clone $REPO_URL ./repo.tmp
    echo '* * Copying repo out of temp and into current folder'
    mv -f ./repo.tmp/* .
    mv ./repo.tmp/.git .
    echo '* * Deleting empty temp folder'
    rm -rf ./repo.tmp
    echo '* Pack Installation Complete!'
    echo '* Exiting in 3 seconds'
    echo '****************************************'
    sleep 3
    exit 0
}

UpdatePack() {
    echo '* Updating SMC Long Term from Gitlab'
    echo '* * Fetching changes from upstream'
    git fetch
    echo '* * Hard resetting local to match upstream'
    git reset --hard HEAD
    echo '* * Merging changes fetched from upstream'
    git merge origin/main
    echo '* Pack Update Complete!'
    echo '* Exiting in 3 seconds'
    echo '****************************************'
    sleep 3
    exit 0
}

GitRepoCheck() {
    if [ -d ".git/" ]; then
        echo '* Detected git repo. Updating Pack!'
        UpdatePack
    else
        echo '* No .git folder was found. Installing Pack!'
        InstallPack
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
echo '* Launching SMC Long Term'
echo '* Checking for OS Type'
OSCheck
