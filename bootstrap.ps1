# SNUG Online Office - Vibe Coding Setup Bootstrap
# Purpose: short one-liner entry point invoked as `irm <url> | iex`.
#
# Why pure ASCII here:
#   When this script runs in the user's current PowerShell session, the
#   console codepage is typically CP949 (Korean Windows default). Writing
#   Korean before chcp 65001 would render garbled text. setup.bat is the
#   first thing that sets chcp 65001, after which all Korean output from
#   setup.ps1 renders correctly. So this bootstrap stays English-only.

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'

$base = 'https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main'
$dir  = Join-Path $env:TEMP 'snug-setup'
New-Item -ItemType Directory -Path $dir -Force | Out-Null

Write-Host '[bootstrap] Downloading setup.bat / setup.ps1 ...' -ForegroundColor Cyan
Invoke-WebRequest -UseBasicParsing -Uri "$base/setup.bat" -OutFile (Join-Path $dir 'setup.bat')
Invoke-WebRequest -UseBasicParsing -Uri "$base/setup.ps1" -OutFile (Join-Path $dir 'setup.ps1')

Write-Host '[bootstrap] Launching setup.bat ...' -ForegroundColor Cyan
& (Join-Path $dir 'setup.bat')
