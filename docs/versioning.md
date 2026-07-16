# Versioning and pairing

A release tag records the independent source versions exactly:

```text
openssh-portable-<portable-version>__win32-openssh-<windows-version>
```

The scheduled workflow takes the newest non-draft official Portable OpenSSH
release and newest non-draft PowerShell Win32-OpenSSH release, including
pre-releases. If either changes, their new combination is published.

This is a registry snapshot, not a compatibility assertion. `manifest.json`
records both upstream versions and URLs and contains
`"compatibility_claim": false`.
