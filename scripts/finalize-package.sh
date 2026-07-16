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
jq -n --arg snapshot "$snapshot" --arg platform "$platform" \
  --arg portable "$portable_version" --arg windows "$windows_version" \
  '{snapshot:$snapshot, platform:$platform, portable_openssh_version:$portable, win32_openssh_version:$windows, compatibility_claim:false}' > "$dir/manifest.json"
