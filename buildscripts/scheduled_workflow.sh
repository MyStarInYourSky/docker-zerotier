#!/bin/bash

# Install Dependencies
sudo apt update && apt -y install jq curl
sudo pip3 install semver

export LATEST_VERSION=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/zerotier/ZeroTierOne/releases | jq -r '.[] | select(.prerelease == false)| select(.draft == false) | .tag_name' | sort -V | tail -1)
export REGISTRY_VERSION=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "Authorization: Bearer ${gh_token}" https://api.github.com/orgs/MyStarInYourSky/packages/container/zerotier/versions | jq -r '.[].metadata.container.tags.[]| select(. != "latest")' | sort -V  | tail -1)

if [ $(./buildscripts/do_we_build.py "$LATEST_VERSION" "$REGISTRY_VERSION") == True ]; then
    export TARGET_VERSION=$(./buildscripts/bump_revision.py "$LATEST_VERSION")
    docker build --build-arg ZEROTIER_VERSION=$LATEST_VERSION --build-arg CONTAINER_VERSION=$TARGET_VERSION  -t ghcr.io/mystarinyoursky/zerotier:$TARGET_VERSION -t ghcr.io/mystarinyoursky/zerotier:latest .
    docker image push ghcr.io/mystarinyoursky/zerotier:$TARGET_VERSION
    docker image push ghcr.io/mystarinyoursky/zerotier:latest
fi