# Archive layout

Every release asset has one top-level directory named after its archive. All
runtime files live directly in that directory.

```text
portable-openssh-<snapshot>-<platform>/
  ssh[.exe]
  sshd[.exe]
  scp[.exe]
  sftp[.exe]
  ssh-add[.exe]
  ssh-agent[.exe]
  ssh-keygen[.exe]
  ssh-keyscan[.exe]
  sftp-server[.exe]
  ssh_config
  sshd_config
  LICENSE
  README.txt
  manifest.json
  <required .dll or .dylib files>
```

Some programs are optional in a given upstream archive. The validator requires
the client tools, `sshd`, and the metadata files. It rejects directories in
the packaged root, except the single top-level archive directory itself.
