@echo off
setlocal
title SNUG Online Office - Installer

REM ============================================================
REM  SNUG Online Office - Vibe Coding ONE-CLICK Installer
REM
REM  Purpose: first-time users who have NOT cloned the repo.
REM  Double-click this single file. It downloads bootstrap.ps1
REM  from GitHub and runs it, which in turn fetches setup.bat /
REM  setup.ps1 and performs the full install. No git clone, no
REM  typing commands required.
REM
REM  Pure ASCII on purpose: cmd.exe reads .bat in OEM codepage,
REM  UTF-8 Korean would corrupt commands. Korean output comes
REM  later from setup.ps1 (after it switches to UTF-8).
REM ============================================================

chcp 65001 >nul

echo.
echo ============================================================
echo    SNUG Online Office - Vibe Coding One-Click Installer
echo ============================================================
echo.
echo  Downloading setup from GitHub and starting install...
echo  (This can take a few minutes. Please keep this window open.)
echo.

set "URL=https://raw.githubusercontent.com/tgtec26/snug-vibe-coding-setup/main/bootstrap.ps1"

REM Use Windows PowerShell 5.1 (always present) to bootstrap.
REM setup.bat installs PowerShell 7 later if needed.
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol='Tls12'; iex (irm '%URL%')"

if errorlevel 1 (
    echo.
    echo  [ERROR] Install failed. Check your internet connection and try again.
)

echo.
echo ============================================================
echo  Installer finished. You can close this window.
echo ============================================================
pause
endlocal
