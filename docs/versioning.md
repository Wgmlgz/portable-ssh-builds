# Versioning and pairing

A release tag records the independent source versions exactly:

```text
openssh-portable-<portable-version>__win32-openssh-<windows-version>
```

The scheduled workflow takes the newest non-draft official Portable OpenSSH
release and newest non-draft PowerShell Win32-OpenSSH release, including
pre-releases. If either changes, their new combination is published.

This is a registry snapshot, not a compatibility assertion. The workflow
creates a public release before building and uploads each completed asset
immediately. Once every platform succeeds, it finalizes that release; a partial
release remains available while a delayed platform is still building.
`manifest.json`
records both upstream versions and URLs and contains
`"compatibility_claim": false`.
