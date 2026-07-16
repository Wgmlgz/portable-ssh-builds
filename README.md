# Portable OpenSSH builds

This repository publishes flat, cross-platform OpenSSH archives on GitHub
Releases. Every release is a snapshot of two independently selected upstream
versions:

`openssh-portable-<portable-version>__win32-openssh-<windows-version>`

It does **not** claim that the two versions are protocol or feature parity.
Use the versions in the release title and `manifest.json` to select the build
you need.

## Platforms

- Linux x86_64 and aarch64: built from official `openssh-portable` source on
  musl, with OpenSSL and zlib linked statically where the toolchain supports it.
- macOS x86_64 and arm64: built for macOS 11 or newer; non-system dynamic
  libraries are placed beside the programs.
- Windows x86_64: the official PowerShell Win32-OpenSSH ZIP, repackaged into
  the common flat layout.

## Archive contract

The archive extracts to one directory. Programs, runtime libraries, example
configuration, licence files and `manifest.json` live directly in that
directory; there are no `bin`, `lib`, or `sbin` subdirectories. Add that
directory to `PATH` to use the client programs.

See [docs/archive-layout.md](docs/archive-layout.md) and
[docs/versioning.md](docs/versioning.md) for the precise contract.

## Publishing

`.github/workflows/publish.yml` runs on pushes to `main` and daily. It selects
the newest upstream snapshot and publishes only when this repository does not
already have that exact snapshot tag. It creates a public release before
building, uploads each completed platform archive immediately, then finalizes
the release after every platform succeeds.
