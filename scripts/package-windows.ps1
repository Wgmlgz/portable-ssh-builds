param(
  [Parameter(Mandatory = $true)][string]$AssetUrl,
  [Parameter(Mandatory = $true)][string]$OutDir,
  [string]$Sha256 = ''
)
$ErrorActionPreference = 'Stop'
$zip = Join-Path $env:RUNNER_TEMP 'OpenSSH-Win64.zip'
$work = Join-Path $env:RUNNER_TEMP 'openssh-win64'
Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $OutDir, $work | Out-Null
Invoke-WebRequest -Uri $AssetUrl -OutFile $zip
if ($Sha256) {
  $actual = (Get-FileHash -Path $zip -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -ne $Sha256.ToLowerInvariant()) { throw "Windows archive SHA-256 mismatch." }
}
Expand-Archive -Path $zip -DestinationPath $work -Force
$payload = Get-ChildItem -Path $work -Directory | Select-Object -First 1
if ($null -eq $payload) { throw 'Expected one top-level directory in Win32 OpenSSH ZIP.' }
Get-ChildItem -Path $payload.FullName -File | ForEach-Object {
  Copy-Item $_.FullName -Destination $OutDir -Force
}
foreach ($config in @('ssh_config', 'sshd_config')) {
  if (-not (Test-Path (Join-Path $OutDir $config))) {
    $default = Join-Path $OutDir "${config}_default"
    if (Test-Path $default) { Copy-Item $default (Join-Path $OutDir $config) }
  }
}
if (-not (Test-Path (Join-Path $OutDir 'LICENSE'))) {
  $licence = Get-ChildItem -Path $OutDir -Filter 'LICEN*' | Select-Object -First 1
  if ($licence) { Rename-Item $licence.FullName 'LICENSE' }
}
