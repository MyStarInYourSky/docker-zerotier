#!/usr/bin/env python3
import semver
import sys
latest_version = semver.Version.parse(sys.argv[1])
registry_version = semver.Version.parse(sys.argv[2])
prerelease = registry_version.prerelease
latest_version_patched = latest_version.replace(prerelease=prerelease)
print(latest_version_patched>registry_version)