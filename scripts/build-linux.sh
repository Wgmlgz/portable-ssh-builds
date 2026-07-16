#!/usr/bin/env bash
set -euo pipefail
version=${1:?portable version required}
out=${2:?output directory required}
source_base=https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable
tarball="openssh-${version}.tar.gz"
mkdir -p "$out" work
out=$(cd "$out" && pwd)
curl -fsSLO "$source_base/$tarball"
curl -fsSLO "$source_base/$tarball.asc"
curl -fsSL https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/RELEASE_KEY.asc -o RELEASE_KEY.asc
gpg --batch --import RELEASE_KEY.asc
gpg --with-colons --fingerprint 2A3F414E736060BA | awk -F: '$1 == "fpr" {print $10}' | \
  grep -qx '7168B983815A5EEF59A4ADFD2A3F414E736060BA'
gpg --batch --verify "$tarball.asc" "$tarball"
tar -xzf "$tarball" -C work --strip-components=1
cd work
# Alpine supplies static OpenSSL/zlib; PAM and other host-integrated features
# are deliberately disabled by config/build-options.env.
# shellcheck disable=SC1091
source ../config/build-options.env
read -r -a configure_options <<< "$OPENSSH_CONFIGURE_OPTIONS"
export CFLAGS='-O2 -fPIE'
export LDFLAGS='-static'
./configure --prefix=/ --sysconfdir=/ "${configure_options[@]}" \
  --with-ssl-dir=/usr --with-zlib=/usr
make -j"$(getconf _NPROCESSORS_ONLN)"
for program in ssh sshd scp sftp ssh-add ssh-agent ssh-keygen ssh-keyscan sftp-server; do
  [[ -f $program ]] && install -m 0755 "$program" "$out/$program"
done
install -m 0644 ssh_config sshd_config "${out}/" 2>/dev/null || true
install -m 0644 LICENCE "$out/LICENSE"
