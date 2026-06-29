# SNUG Online Office - winget (App Installer) bootstrap
#
# Runs under Windows PowerShell 5.1 BEFORE PowerShell 7 exists, because
# everything in setup.bat / setup.ps1 installs tools via winget, so winget
# must be present first.
#
# Pure ASCII on purpose (same reason as bootstrap.ps1 / setup.bat): this
# stage runs before the console is guaranteed UTF-8-clean for PS 5.1 source
# parsing, so all strings stay English-only.
#
# Exit 0 = winget available (already, or after install).
# Exit 1 = still missing -> caller should stop and show the guidance.

$ErrorActionPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host '  [OK] winget already installed.' -ForegroundColor Green
    exit 0
}

Write-Host '  [INFO] winget (App Installer) not found. Attempting automatic install...' -ForegroundColor Yellow

$tmp = Join-Path $env:TEMP 'snug-winget'
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

$vclibs = Join-Path $tmp 'vclibs.appx'
$xaml   = Join-Path $tmp 'xaml.appx'
$bundle = Join-Path $tmp 'winget.msixbundle'

try {
    # App Installer depends on VCLibs and UI.Xaml; download all three then register.
    Invoke-WebRequest -UseBasicParsing -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile $vclibs
    Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx' -OutFile $xaml
    Invoke-WebRequest -UseBasicParsing -Uri 'https://aka.ms/getwinget' -OutFile $bundle
    Add-AppxPackage -Path $vclibs -ErrorAction SilentlyContinue
    Add-AppxPackage -Path $xaml   -ErrorAction SilentlyContinue
    Add-AppxPackage -Path $bundle -ErrorAction Stop
} catch {
    Write-Host ('  [WARN] Automatic winget install failed: ' + $_.Exception.Message) -ForegroundColor Yellow
}

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host '  [OK] winget installed successfully.' -ForegroundColor Green
    exit 0
}

Write-Host ''
Write-Host '  ============================================================' -ForegroundColor Red
Write-Host '  [ACTION REQUIRED] winget could not be installed automatically.' -ForegroundColor Red
Write-Host '  Your laptop is missing "App Installer", which is required.' -ForegroundColor Red
Write-Host '' -ForegroundColor Red
Write-Host '  Please install it manually, then run this installer again:' -ForegroundColor White
Write-Host '    1) Open Microsoft Store, search "App Installer", install or update it.' -ForegroundColor White
Write-Host '    2) Or run Windows Update (Settings > Windows Update) and reboot.' -ForegroundColor White
Write-Host '    3) Or download directly: https://aka.ms/getwinget' -ForegroundColor White
Write-Host '  ============================================================' -ForegroundColor Red
exit 1
