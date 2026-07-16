#!/usr/bin/env bash
set -euo pipefail
tag=${1:?release tag required}
response=$(mktemp)
status=$(curl -sS -o "$response" -w '%{http_code}' -H "Authorization: Bearer ${GITHUB_TOKEN:?}" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY:?}/releases/tags/$tag")
case "$status" in
  200)
    # A failed run may leave a draft temporarily; it is not a published
    # registry entry and must not prevent a later automatic retry.
    if jq -e '.draft == false and .prerelease == false' "$response" >/dev/null; then
      echo 'exists=true' >> "$GITHUB_OUTPUT"
    else
      echo 'exists=false' >> "$GITHUB_OUTPUT"
    fi
    ;;
  404) echo 'exists=false' >> "$GITHUB_OUTPUT" ;;
  *) echo "GitHub release query failed with HTTP $status" >&2; exit 1 ;;
esac
rm -f "$response"
