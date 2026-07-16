#!/usr/bin/env bash
set -euo pipefail

# Emits GitHub Actions outputs for the newest upstream snapshot, or explicit
# tags supplied by workflow_dispatch. GitHub's release API returns newest first.
api=https://api.github.com/repos
portable_repo=openssh/openssh-portable
windows_repo=PowerShell/Win32-OpenSSH
auth=()
if [[ -n ${GITHUB_TOKEN:-} ]]; then
  auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

get_windows_release() {
  local requested=${1:-}
  if [[ -n $requested ]]; then
    curl -fsSL "${auth[@]}" \
      "$api/$windows_repo/releases/tags/$requested"
  else
    curl -fsSL "${auth[@]}" \
      "$api/$windows_repo/releases?per_page=100" | jq '[.[] | select(.draft | not)][0]'
  fi
}

portable_tag=${PORTABLE_TAG:-}
if [[ -z $portable_tag ]]; then
  # openssh-portable publishes source release tags but not GitHub Releases.
  # The tags endpoint is newest-first; sorting makes that assumption explicit.
  portable_tag=$(curl -fsSL "${auth[@]}" \
    "$api/$portable_repo/tags?per_page=100" | jq -r '.[].name' | grep -E '^V_[0-9]+_' | \
    while read -r tag; do
      version=$(sed -E 's/^V_//; s/_([Pp])([0-9]+)/\1\2/; s/_/./g' <<<"$tag" | tr '[:upper:]' '[:lower:]')
      printf '%s\t%s\n' "$version" "$tag"
    done | sort -V | tail -n 1 | cut -f2)
fi
curl -fsS "${auth[@]}" -o /dev/null -w '%{http_code}' "$api/$portable_repo/git/ref/tags/$portable_tag" | grep -qx 200 || {
  echo "Portable OpenSSH tag not found: $portable_tag" >&2; exit 1;
}
windows_json=$(get_windows_release "${WINDOWS_TAG:-}")
windows_tag=$(jq -er .tag_name <<<"$windows_json")

# Portable tags use V_10_0_P2; official source archives use 10.0p2.
portable_version=$(sed -E 's/^V_//; s/_([Pp])([0-9]+)/\1\2/; s/_/./g' <<<"$portable_tag" | tr '[:upper:]' '[:lower:]')
windows_version=${windows_tag#v}
windows_asset_url=$(jq -er '.assets[] | select(.name == "OpenSSH-Win64.zip") | .browser_download_url' <<<"$windows_json")
windows_asset_sha256=$(jq -r '.assets[] | select(.name == "OpenSSH-Win64.zip") | .digest // empty' <<<"$windows_json" | sed 's/^sha256://')
snapshot="openssh-portable-${portable_version}__win32-openssh-${windows_version,,}"

{
  echo "portable_tag=$portable_tag"
  echo "portable_version=$portable_version"
  echo "windows_tag=$windows_tag"
  echo "windows_version=$windows_version"
  echo "windows_asset_url=$windows_asset_url"
  echo "windows_asset_sha256=$windows_asset_sha256"
  echo "snapshot=$snapshot"
} >> "${GITHUB_OUTPUT:?GITHUB_OUTPUT must be set}"
