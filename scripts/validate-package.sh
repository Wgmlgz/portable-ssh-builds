#!/usr/bin/env bash
set -euo pipefail
dir=${1:?package directory required}
platform=${2:?platform required}
suffix=''
[[ $platform == windows-* ]] && suffix=.exe
for tool in ssh sshd scp sftp ssh-keygen; do
  [[ -f "$dir/$tool$suffix" ]] || { echo "missing $tool$suffix" >&2; exit 1; }
done
for metadata in LICENSE README.txt manifest.json; do
  [[ -f "$dir/$metadata" ]] || { echo "missing $metadata" >&2; exit 1; }
done
find "$dir" -mindepth 1 -type d -print -quit | grep -q . && {
  echo 'package must be flat; directories are not allowed' >&2; exit 1;
}
