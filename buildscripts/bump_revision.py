#!/usr/bin/env python3
from semver.version import Version
import sys
target_version = sys.argv[1]
print(str(Version.parse(target_version).bump_prerelease('')))