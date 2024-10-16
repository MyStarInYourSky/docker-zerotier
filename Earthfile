VERSION 0.8
container-update:
    FROM ubuntu:noble
    ARG gh_token
    RUN apt update && apt -y install jq curl
    RUN --no-cache curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/zerotier/ZeroTierOne/releases | jq -r '.[] | select(.prerelease == false)| select(.draft == false) | .tag_name' | sort -V | tail -1 > /tmp/zerotier_latest_version
    RUN --no-cache --secret gh_token=gh_token curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "Authorization: Bearer ${gh_token}" https://api.github.com/orgs/MyStarInYourSky/packages/container/zerotier/versions | jq -r '.[].metadata.container.tags.[]| select(. != "latest")' | sort -V  | tail -1 > /tmp/latest_registry_version
    ARG ZEROTIER_LATEST_VERSION=$(cat /tmp/zerotier_latest_version)
    ARG LATEST_REGISTRY_VERSION=$(cat /tmp/latest_registry_version)
    FROM python:3
    RUN pip3 install semver
    RUN echo "#!/usr/bin/env python3
from semver.version import Version
import sys
target_version = sys.argv[1]
print(str(Version.parse(target_version).bump_prerelease('')))
    " > ./target_version && chmod +x target_version
    RUN --no-cache ./target_version "$LATEST_REGISTRY_VERSION" > target_version_result
    BUILD +release --CONTAINER_VER=$(cat target_version_result) --TARGET_VER=$ZEROTIER_LATEST_VERSION
app-update:
    FROM ubuntu:noble
    ARG gh_token
    RUN apt update && apt -y install jq curl
    RUN --no-cache curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/zerotier/ZeroTierOne/releases | jq -r '.[] | select(.prerelease == false)| select(.draft == false) | .tag_name' | sort -V | tail -1 > /tmp/zerotier_latest_version
    RUN --no-cache --secret gh_token=gh_token curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "Authorization: Bearer ${gh_token}" https://api.github.com/orgs/MyStarInYourSky/packages/container/zerotier/versions | jq -r '.[].metadata.container.tags.[]| select(. != "latest")' | sort -V  | tail -1 > /tmp/latest_registry_version
    ARG ZEROTIER_LATEST_VERSION=$(cat /tmp/zerotier_latest_version)
    ARG LATEST_REGISTRY_VERSION=$(cat /tmp/latest_registry_version)
    FROM python:3
    RUN pip3 install semver
    RUN echo "#!/usr/bin/env python3
import semver
import sys
latest_version = semver.Version.parse(sys.argv[1])
registry_version = semver.Version.parse(sys.argv[2])
prerelease = registry_version.prerelease
latest_version_patched = latest_version.replace(prerelease=prerelease)
print(latest_version_patched>registry_version)
    " > ./do_we_build && chmod +x do_we_build
    RUN echo "#!/usr/bin/env python3
from semver.version import Version
import sys
target_version = sys.argv[1]
print(str(Version.parse(target_version).bump_prerelease('')))
    " > ./target_version && chmod +x target_version
    RUN --no-cache ./do_we_build "$ZEROTIER_LATEST_VERSION" "$LATEST_REGISTRY_VERSION" > do_we_build_result
    IF [ $(cat do_we_build_result) = "True" ]
        RUN --no-cache ./target_version "$LATEST_REGISTRY_VERSION" > target_version_result
        BUILD +release --CONTAINER_VER=$(cat target_version_result) --TARGET_VER=$ZEROTIER_LATEST_VERSION
    END
release:
    ARG TARGET_VER
    ARG CONTAINER_VER
    FROM DOCKERFILE --build-arg ZEROTIER_VERSION=$TARGET_VER --build-arg CONTAINER_VERSION=$CONTAINER_VER .
    SAVE IMAGE --push ghcr.io/mystarinyoursky/zerotier:$CONTAINER_VER ghcr.io/mystarinyoursky/zerotier:latest