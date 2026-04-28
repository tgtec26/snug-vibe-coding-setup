@echo off
setlocal
title SNUG Online Office - Setup Launcher

REM ============================================================
REM  SNUG Online Office - Vibe Coding Setup Launcher (.bat)
REM  IMPORTANT: This file is intentionally pure ASCII (no Korean).
REM  cmd.exe reads .bat files in OEM codepage; UTF-8 Korean would
REM  corrupt commands. All Korean messages live in setup.ps1.
REM ============================================================

REM Set console to UTF-8 BEFORE launching pwsh, so pwsh inherits
REM a UTF-8 console from the start (prevents Korean char doubling
REM caused by mid-execution codepage switch).
chcp 65001 >nul

REM Switch to script's own folder so we can use a relative path
REM (avoids passing the Korean path to PowerShell as an argument).
cd /d "%~dp0"

echo.
echo ============================================================
echo    SNUG Online Office - Setup Launcher
echo ============================================================
echo.

if not exist "setup.ps1" (
    echo  [ERROR] setup.ps1 not found in this folder.
    echo          Make sure setup.bat and setup.ps1 are in the same folder.
    echo.
    pause
    exit /b 1
)

echo  Target script: %CD%\setup.ps1
echo.

REM === Choose available PowerShell (prefer 7) ===
where pwsh >nul 2>nul
if %ERRORLEVEL%==0 (
    set "PS=pwsh"
    echo  [OK] PowerShell 7 detected. Using pwsh.exe.
) else (
    set "PS=powershell"
    echo  [INFO] PowerShell 7 not found. Falling back to Windows PowerShell 5.1.
)
echo.

REM === 1) Remove MotW (Mark of the Web) added by Google Drive sync ===
echo  [1/2] Unblocking script file...
%PS% -NoProfile -Command "Unblock-File -Path '.\setup.ps1' -ErrorAction SilentlyContinue"

REM === 2) Run installer with bypassed execution policy ===
echo  [2/2] Running setup.ps1 ...
echo.
%PS% -NoProfile -ExecutionPolicy Bypass -File "setup.ps1"

echo.
echo ============================================================
echo  Launcher finished. You can close this window.
echo ============================================================
pause
endlocal