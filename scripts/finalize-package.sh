#!/usr/bin/env bash
set -euo pipefail
dir=${1:?package directory required}
snapshot=${2:?snapshot required}
platform=${3:?platform required}
portable_version=${4:?portable version required}
windows_version=${5:?windows version required}
mkdir -p "$dir"
cat > "$dir/README.txt" <<EOF
Portable OpenSSH snapshot: $snapshot
Platform: $platform
Add this directory to PATH. This snapshot records independent upstream versions;
it does not claim Portable OpenSSH and Win32-OpenSSH feature parity.
EOF
# Keep this dependency-free: GitHub's Windows runners provide Bash but do not
# guarantee jq. These fields are upstream release tags/platform identifiers and
# are constrained by discovery, so they cannot contain JSON quoting characters.
cat > "$dir/manifest.json" <<EOF
{"snapshot":"$snapshot","platform":"$platform","portable_openssh_version":"$portable_version","win32_openssh_version":"$windows_version","compatibility_claim":false}
EOF
