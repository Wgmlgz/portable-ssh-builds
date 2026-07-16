#!/usr/bin/env bash
set -euo pipefail
tag=${1:?release tag required}
status=$(curl -sS -o /dev/null -w '%{http_code}' -H "Authorization: Bearer ${GITHUB_TOKEN:?}" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY:?}/releases/tags/$tag")
case "$status" in
  200) echo 'exists=true' >> "$GITHUB_OUTPUT" ;;
  404) echo 'exists=false' >> "$GITHUB_OUTPUT" ;;
  *) echo "GitHub release query failed with HTTP $status" >&2; exit 1 ;;
esac
