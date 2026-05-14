# 🚦 [배포용] SNUG 온라인 오피스 바이브 코딩(AI 보조 코딩) 환경 설정 스크립트
# 작성일: 2026-04-14 (확장 개편: 2026-04-27)
# 용도: 동료 교사용 Claude / Gemini 기반 바이브 코딩 환경 자동 세팅 (Windows 전용)

# === PowerShell 7 자동 승격 ===
# 우클릭→Windows PowerShell 5.1로 실행되더라도 자동으로 7로 재실행되도록 처리.
# 5.1에서는 한글 인코딩/연산자(&&, ||) 호환 문제가 발생하므로 7 이상에서만 본문을 실행한다.
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $pwsh = "C:\Program Files\PowerShell\7\pwsh.exe"
    if (Test-Path $pwsh) {
        Write-Host "PowerShell 7으로 다시 실행합니다..." -ForegroundColor Yellow
        Start-Process -FilePath $pwsh -ArgumentList "-NoExit","-ExecutionPolicy","Bypass","-File","`"$PSCommandPath`""
        exit
    } else {
        Write-Warning "PowerShell 7이 설치되어 있지 않습니다."
        Write-Host "먼저 https://aka.ms/pscore6 에서 PowerShell 7을 설치한 뒤 다시 실행해 주세요." -ForegroundColor Cyan
        pause
        exit
    }
}

# === 한글 인코딩(UTF-8) ===
# 콘솔 코드페이지는 setup.bat에서 pwsh 실행 전에 이미 65001(UTF-8)로 설정된다.
# 여기서 chcp를 다시 호출하면 출력 버퍼가 꼬여 첫 몇 줄에서 한글이 중복(예: "확확인인")으로
# 보이는 현상이 발생하므로, .NET 측 인코딩만 안전장치로 일치시킨다.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# === 관리자 권한 체크 ===
# winget 일부 패키지(Node.js, Git 등)는 관리자 권한이 필요할 수 있다.
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "관리자 권한으로 실행되지 않았습니다. winget 일부 설치가 실패할 수 있습니다."
    Write-Host "  → 설치 실패 시 PowerShell 7을 '관리자 권한으로 실행' 후 재시도해 주세요." -ForegroundColor Cyan
}

# === PATH 환경변수 새로고침 + 콘솔 VT 모드 복원 헬퍼 ===
# winget 등 일부 설치 프로그램이 실행되면 콘솔 VT 모드(ENABLE_VIRTUAL_TERMINAL_PROCESSING)를
# 꺼버려 이후 ANSI 색상 코드가 두 글자씩 겹쳐 출력되는 버그가 발생한다.
# kernel32 SetConsoleMode API로 플래그를 다시 켜서 복원한다.
function Reset-ConsoleVT {
    try {
        Add-Type -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
[DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);
[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
'@ -Name 'KernelVT' -Namespace 'Win32' -ErrorAction SilentlyContinue
    } catch {}
    try {
        $h = [Win32.KernelVT]::GetStdHandle(-11)   # STD_OUTPUT_HANDLE
        $m = 0
        [void][Win32.KernelVT]::GetConsoleMode($h, [ref]$m)
        [void][Win32.KernelVT]::SetConsoleMode($h, $m -bor 0x0004)  # ENABLE_VIRTUAL_TERMINAL_PROCESSING
    } catch {}
}
function Reload-Path {
    $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH','Machine') + ";" + [System.Environment]::GetEnvironmentVariable('PATH','User')
    Reset-ConsoleVT
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    SNUG 온라인 오피스 바이브 코딩 환경 설치를 시작합니다" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. PowerShell 버전 / 인코딩 상태 확인
Write-Host "
[1/8] PowerShell 버전 / 한글 인코딩 확인 중..." -ForegroundColor Yellow
Write-Host "  ✓ PowerShell $($PSVersionTable.PSVersion) 환경" -ForegroundColor Green
Write-Host "  ✓ UTF-8 콘솔 인코딩 적용됨" -ForegroundColor Green

# 2. Node.js 및 npm 설치 확인 (없으면 winget으로 자동 설치 시도)
Write-Host "
[2/8] 필수 엔진(Node.js) 점검 중..." -ForegroundColor Yellow
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "  Node.js 미설치. winget으로 자동 설치를 시도합니다..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install -e --id OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements
        Reload-Path
    }
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Error "Node.js 자동 설치에 실패했습니다."
        Write-Host "https://nodejs.org/ 에서 'LTS 버전'을 수동 설치하고 다시 실행해 주세요." -ForegroundColor Red
        pause
        exit
    }
}
$nodeVer = (& node --version) 2>$null
Write-Host "  ✓ Node.js $nodeVer 확인되었습니다." -ForegroundColor Green

# 3. 보조 도구(Git, 코드 에디터, Python, gh, OpenJDK, pipx, opendataloader-pdf) 점검 및 자동 설치
Write-Host "
[3/8] 보조 도구(Git / 에디터 / Python / gh / OpenJDK / pipx / opendataloader-pdf / uv / serena / WSL / rtk) 점검 중..." -ForegroundColor Yellow

# Git: 버전 관리 / GitHub 연동에 필수 — 미설치 시 winget으로 자동 설치
if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVer = (& git --version) 2>$null
    Write-Host "  ✓ Git 확인됨 ($gitVer)" -ForegroundColor Green
} else {
    Write-Host "  · Git 미설치. winget으로 자동 설치를 시도합니다..." -ForegroundColor Gray
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install -e --id Git.Git --silent --accept-package-agreements --accept-source-agreements
        Reload-Path
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ Git 설치 완료" -ForegroundColor Green
        } else {
            Write-Warning "  ✗ Git 자동 설치 실패. 수동 설치: https://git-scm.com/download/win"
        }
    } else {
        Write-Warning "  ✗ winget 미지원. 수동 설치: https://git-scm.com/download/win"
    }
}

# 코드 에디터: VS Code 또는 Cursor 권장
$editorFound = $false
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ Visual Studio Code 확인됨" -ForegroundColor Green
    $editorFound = $true
}
if (Get-Command cursor -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ Cursor 확인됨" -ForegroundColor Green
    $editorFound = $true
}
if (-not $editorFound) {
    Write-Warning "  ✗ 코드 에디터가 감지되지 않았습니다."
    Write-Host "    VS Code(권장):  https://code.visualstudio.com/" -ForegroundColor Cyan
    Write-Host "    Cursor(AI 편집기): https://cursor.com/" -ForegroundColor Cyan
}

# Python: 일부 AI 도구·MCP 서버에서 사용
if (Get-Command python -ErrorAction SilentlyContinue) {
    $pyVer = (& python --version) 2>$null
    Write-Host "  ✓ Python 확인됨 ($pyVer)" -ForegroundColor Green
} else {
    Write-Host "  · Python은 감지되지 않았지만 필수는 아닙니다. (MCP·일부 AI 도구 사용 시 필요)" -ForegroundColor Gray
    Write-Host "    설치 링크: https://www.python.org/downloads/" -ForegroundColor Cyan
}

# GitHub CLI(gh): GitHub 저장소·PR·이슈 관리. npm이 아닌 별도 설치 — winget으로 자동 설치 시도.
if (Get-Command gh -ErrorAction SilentlyContinue) {
    $ghLine = (& gh --version 2>$null | Select-Object -First 1)
    Write-Host "  ✓ GitHub CLI 확인됨 ($ghLine)" -ForegroundColor Green
} else {
    Write-Host "  · GitHub CLI(gh) 미설치. winget으로 자동 설치를 시도합니다..." -ForegroundColor Gray
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id GitHub.cli -e --silent --accept-package-agreements --accept-source-agreements
        Reset-ConsoleVT
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ GitHub CLI(gh) 설치 완료. 새 터미널을 열어 'gh' 명령을 사용하세요." -ForegroundColor Green
        } else {
            Write-Warning "  ✗ winget 설치가 즉시 반영되지 않았습니다. 새 터미널에서 'gh' 동작 여부를 확인해 주세요."
            Write-Host "    수동 설치 링크: https://cli.github.com/" -ForegroundColor Cyan
        }
    } else {
        Write-Warning "  ✗ winget을 찾을 수 없습니다. 수동 설치가 필요합니다."
        Write-Host "    설치 링크: https://cli.github.com/" -ForegroundColor Cyan
    }
}

# OpenJDK: Java 런타임 (PDF 변환 도구 opendataloader-pdf 등에 필요)
if (Get-Command java -ErrorAction SilentlyContinue) {
    $javaLine = (& java -version 2>&1 | Select-Object -First 1)
    Write-Host "  ✓ Java 확인됨 ($javaLine)" -ForegroundColor Green
} else {
    Write-Host "  · OpenJDK 미설치. winget으로 자동 설치를 시도합니다..." -ForegroundColor Gray
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install -e --id Microsoft.OpenJDK.21 --silent --accept-package-agreements --accept-source-agreements
        Reload-Path
        if (Get-Command java -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ OpenJDK 설치 완료" -ForegroundColor Green
        } else {
            Write-Warning "  ✗ OpenJDK 자동 설치 실패. 새 터미널에서 'java -version' 확인 후 재실행해 주세요."
            Write-Host "    수동 설치: https://learn.microsoft.com/java/openjdk/download" -ForegroundColor Cyan
        }
    } else {
        Write-Warning "  ✗ winget을 찾을 수 없어 OpenJDK 자동 설치 불가."
        Write-Host "    수동 설치: https://learn.microsoft.com/java/openjdk/download" -ForegroundColor Cyan
    }
}

# pipx: 격리된 Python CLI 도구 설치 (opendataloader-pdf 등)
# pip install --user 방식은 Windows에서 PATH 반영이 불안정하므로 scoop을 사용한다.
if (Get-Command pipx -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ pipx 확인됨" -ForegroundColor Green
} else {
    # scoop이 없으면 먼저 설치
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  · scoop 미설치. pipx 설치를 위해 scoop을 먼저 설치합니다..." -ForegroundColor Gray
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Reload-Path
    }
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "  · pipx 미설치. scoop으로 설치를 시도합니다..." -ForegroundColor Gray
        scoop install pipx 2>&1 | Out-Null
        Reload-Path
        if (Get-Command pipx -ErrorAction SilentlyContinue) {
            pipx ensurepath 2>&1 | Out-Null
            Write-Host "  ✓ pipx 설치 완료 (via scoop)" -ForegroundColor Green
        } else {
            Write-Warning "  ✗ pipx 설치 실패. 수동: scoop install pipx"
        }
    } else {
        Write-Warning "  ✗ scoop 설치 실패. 아래 명령어로 수동 설치 후 재실행하세요."
        Write-Host "    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
        Write-Host "    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression" -ForegroundColor Cyan
    }
}

# opendataloader-pdf: PDF → Markdown/JSON 변환 CLI (내부적으로 Java 11+ 사용)
if (Get-Command opendataloader-pdf -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ opendataloader-pdf 확인됨" -ForegroundColor Green
} elseif (Get-Command pipx -ErrorAction SilentlyContinue) {
    Write-Host "  · opendataloader-pdf 미설치. pipx로 설치를 시도합니다..." -ForegroundColor Gray
    pipx install opendataloader-pdf 2>&1 | Out-Null
    if (Get-Command opendataloader-pdf -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ opendataloader-pdf 설치 완료" -ForegroundColor Green
    } else {
        Write-Warning "  ✗ opendataloader-pdf 설치 실패. 수동: pipx install opendataloader-pdf"
    }
} else {
    Write-Host "  · pipx가 없어 opendataloader-pdf 설치를 건너뜁니다." -ForegroundColor Gray
}

# uv: 빠른 Python 패키지 매니저 (Serena 등 Python 기반 MCP/도구 설치에 사용)
if (Get-Command uv -ErrorAction SilentlyContinue) {
    $uvVer = (& uv --version) 2>$null
    Write-Host "  ✓ uv 확인됨 ($uvVer)" -ForegroundColor Green
} else {
    Write-Host "  · uv 미설치. winget으로 자동 설치를 시도합니다..." -ForegroundColor Gray
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install -e --id astral-sh.uv --silent --accept-package-agreements --accept-source-agreements
        Reload-Path
        if (Get-Command uv -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ uv 설치 완료" -ForegroundColor Green
        } else {
            Write-Warning "  ✗ uv 자동 설치 실패. 수동: winget install astral-sh.uv"
        }
    } else {
        Write-Warning "  ✗ winget을 찾을 수 없어 uv 자동 설치 불가."
        Write-Host "    수동 설치: https://docs.astral.sh/uv/getting-started/installation/" -ForegroundColor Cyan
    }
}

# serena: 코드베이스 시맨틱 분석 MCP 서버 (uv tool 로 격리 설치)
# 공식 권장: 마켓플레이스 설치 금지 → 반드시 uv tool install 경로 사용
if (Get-Command serena -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ serena 확인됨" -ForegroundColor Green
} elseif (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host "  · serena 미설치. uv tool 로 설치를 시도합니다..." -ForegroundColor Gray
    uv tool install -p 3.13 serena-agent@latest --prerelease=allow 2>&1 | Out-Null
    Reload-Path
    if (Get-Command serena -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ serena 설치 완료" -ForegroundColor Green
    } else {
        Write-Warning "  ✗ serena 설치 실패. 수동: uv tool install -p 3.13 serena-agent@latest --prerelease=allow"
    }
} else {
    Write-Host "  · uv가 없어 serena 설치를 건너뜁니다." -ForegroundColor Gray
}

# WSL: rtk 등 Linux 전용 도구 실행용 Windows Subsystem for Linux
# 'wsl -l -q' 가 비어있지 않으면 distro 설치된 상태. 없으면 'wsl --install --no-launch'로 자동 설치.
# 첫 설치는 관리자 권한 필요 + 재부팅 후 Ubuntu 초기 설정(사용자명/비밀번호) 필요.
$wslInstalled = $false
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    $wslDistros = (wsl -l -q 2>$null) -join "" -replace "`0",""
    if ($wslDistros.Trim()) {
        Write-Host "  ✓ WSL 확인됨 (설치된 distro: $($wslDistros.Trim() -split "`r?`n" -join ', '))" -ForegroundColor Green
        $wslInstalled = $true
    }
}
if (-not $wslInstalled) {
    if ($isAdmin) {
        Write-Host "  · WSL 미설치. 'wsl --install --no-launch' 로 자동 설치를 시도합니다... (재부팅 필요)" -ForegroundColor Gray
        wsl --install --no-launch 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ WSL 설치 명령 실행 완료. 재부팅 후 Ubuntu 초기 설정(사용자명/비밀번호)을 마쳐야 합니다." -ForegroundColor Green
        } else {
            Write-Warning "  ✗ WSL 자동 설치 실패. 수동: 관리자 PowerShell에서 'wsl --install'"
        }
    } else {
        Write-Warning "  ✗ WSL 미설치. 자동 설치는 관리자 권한이 필요합니다."
        Write-Host "    수동: 관리자 PowerShell에서 'wsl --install' 실행 후 재부팅" -ForegroundColor Cyan
    }
}

# rtk: AI CLI Bash 출력 압축 도구 (Windows 네이티브 미지원 — WSL 안에서 설치 권장)
if (Get-Command rtk -ErrorAction SilentlyContinue) {
    Write-Host "  ✓ rtk 확인됨" -ForegroundColor Green
} else {
    Write-Host "  · rtk 미설치. Windows 네이티브 자동 설치는 미지원입니다." -ForegroundColor Gray
    Write-Host "    WSL(권장):  wsl -- bash -c 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh'" -ForegroundColor Cyan
    Write-Host "    네이티브:   https://github.com/rtk-ai/rtk/releases (rtk-x86_64-pc-windows-msvc.zip)" -ForegroundColor Cyan
}

# 4. 인공지능 및 개발 도구 자동 설치 (Global npm Packages)
Write-Host "
[4/8] 인공지능 / 개발 CLI 도구 설치 및 업데이트 중 (잠시만 기다려 주세요)..." -ForegroundColor Yellow

# 일반 npm 글로벌 패키지 (postinstall에서 Expand-Archive를 호출하지 않는 패키지들)
$NPM_GLOBALS = @(
    "@google/gemini-cli@latest",          # Gemini AI CLI (gemini)
    "@anthropic-ai/claude-code@latest",   # Claude Code AI CLI (claude)
    "@google/clasp@latest",               # Google Apps Script 도구 (clasp)
    "firebase-tools@latest",              # Firebase 인증·Firestore·배포 (firebase)
    "vercel@latest",                      # Vercel 웹 배포 (vercel)
    "serve@latest",                       # 로컬 정적 서버 (serve)
    "@playwright/test@latest",            # 웹 자동화·브라우저 테스트
    "xlsx@latest",                        # 엑셀(.xlsx) 파일 처리 라이브러리
    "typescript@latest",                  # TypeScript 컴파일러 (tsc)
    "tsx@latest",                         # TypeScript 즉시 실행 도구 (tsx)
    "@musistudio/claude-code-router@latest"  # Claude Code Router (ccr) — Claude/모델 라우팅
)

foreach ($pkg in $NPM_GLOBALS) {
    Write-Host "  > $pkg 설치 중..."
    npm install -g $pkg --silent
    if ($?) {
        Write-Host "    - $pkg 설치 성공" -ForegroundColor Gray
    } else {
        Write-Warning "    - $pkg 설치 중 오류 발생 (이미 설치되어 있거나 권한 문제일 수 있습니다)"
    }
}

# @googleworkspace/cli (gws) 는 postinstall에서 Expand-Archive(Write-Progress)를 호출해
# 콘솔 VT 상태를 깨뜨리고 그 결과 한글 출력이 두 글자씩 겹쳐 보이는 렌더 버그를 유발한다.
# → 출력을 로그 파일로 리다이렉트하여 진행률 바가 콘솔에 직접 그려지지 않게 한다.
Write-Host "  > @googleworkspace/cli@latest 설치 중... (gws CLI, 진행 상황은 로그 파일로 기록)"
$gwsLog = Join-Path $env:TEMP "snug-setup-gws-install.log"
npm install -g "@googleworkspace/cli@latest" --silent *>> $gwsLog
if ($?) {
    Write-Host "    - @googleworkspace/cli 설치 성공 (로그: $gwsLog)" -ForegroundColor Gray
} else {
    Write-Warning "    - @googleworkspace/cli 설치 실패. 로그 확인: $gwsLog"
}

# 5. Playwright 브라우저 바이너리 설치 (웹 자동화·스크린샷용)
Write-Host "
[5/8] Playwright 브라우저(Chromium) 설치 중..." -ForegroundColor Yellow
Write-Host "  (웹 자동화/스크린샷에 사용. 약 150MB 다운로드)" -ForegroundColor Gray
npx --yes playwright install chromium
if ($?) {
    Write-Host "  Playwright 브라우저 설치 완료" -ForegroundColor Green
} else {
    Write-Warning "  Playwright 브라우저 설치 중 오류가 발생했습니다."
}

# 6. Claude Code MCP 서버 추가 (Claude의 능력을 확장하는 외부 도구들)
Write-Host "
[6/8] Claude Code MCP 서버 추가 중..." -ForegroundColor Yellow
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $mcpList = (claude mcp list 2>$null) | Out-String
    function Add-Mcp {
        param([string]$Name, [string]$Cmd, [string]$Desc)
        if ($mcpList -match [regex]::Escape($Name)) {
            Write-Host "  · MCP $Name : 이미 등록됨 ($Desc)" -ForegroundColor Gray
        } else {
            Write-Host "  > MCP $Name 등록 중... ($Desc)"
            claude mcp add $Name -- $Cmd 2>&1 | Out-Null
            if ($?) {
                Write-Host "    ✓ $Name 등록 완료" -ForegroundColor Green
            } else {
                Write-Warning "    ✗ $Name 등록 실패"
            }
        }
    }
    Add-Mcp "playwright"           "npx @playwright/mcp@latest"                                     "브라우저 자동화/스크린샷"
    Add-Mcp "context7"             "npx -y @upstash/context7-mcp"                                   "라이브러리 공식 문서 검색"
    Add-Mcp "sequential-thinking"  "npx -y @modelcontextprotocol/server-sequential-thinking"        "단계적 사고 도구"
    Add-Mcp "serena"               "serena start-mcp-server --context claude-code --project-from-cwd" "코드베이스 시맨틱 분석"
} else {
    Write-Warning "  claude 명령을 찾을 수 없어 MCP 등록을 건너뜁니다. (Claude Code 설치 후 재실행)"
}

# 7. Claude Code 디자인·프론트엔드 스킬 추가
# pbakaus/impeccable: 디자인 보조 스킬 모음 (frontend-design, polish, delight, animate, audit 등)
# senior-frontend: 시니어 프론트엔드 엔지니어 관점의 코드 리뷰/제안 스킬
Write-Host "
[7/8] Claude Code 추가 스킬·플러그인(impeccable / senior-frontend / hookify / superpowers / caveman) 설치 중..." -ForegroundColor Yellow
Write-Host "  (UI/UX 품질·프론트엔드 코드 품질 + AI 행동 hook 관리 + 워크플로우 자동화 + 출력 압축)" -ForegroundColor Gray

npx --yes skills add pbakaus/impeccable
if ($?) { Write-Host "  ✓ impeccable 스킬 설치 완료" -ForegroundColor Green }
else { Write-Warning "  ✗ impeccable 스킬 설치 실패 (Claude Code 로그인 후 재시도)" }

$skillRoot = Join-Path $env:USERPROFILE ".claude\skills"
if (Test-Path (Join-Path $skillRoot "senior-frontend")) {
    Write-Host "  · senior-frontend 스킬 이미 존재" -ForegroundColor Gray
} else {
    npx -y claude-code-templates@latest --skill development/senior-frontend
    if ($?) { Write-Host "  ✓ senior-frontend 스킬 설치 완료" -ForegroundColor Green }
    else { Write-Warning "  ✗ senior-frontend 스킬 설치 실패" }
}

# Claude Code 공식 마켓플레이스 플러그인 (anthropics/claude-plugins-official)
# - hookify    : 대화 분석/명시적 지시로부터 AI 행동 hook 자동 생성·관리
# - superpowers: 브레인스토밍/계획/TDD/디버깅 등 워크플로우 자동화 스킬 모음
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $pluginList = (claude plugin list 2>$null) | Out-String
    function Install-ClaudePlugin {
        param([string]$Name)
        if ($pluginList -match "${Name}@") {
            Write-Host "  · $Name 플러그인 이미 설치됨" -ForegroundColor Gray
        } else {
            Write-Host "  > $Name 플러그인 설치 중..."
            claude plugin install "${Name}@claude-plugins-official" 2>&1 | Out-Null
            if ($?) {
                Write-Host "  ✓ $Name 플러그인 설치 완료" -ForegroundColor Green
            } else {
                Write-Warning "  ✗ $Name 플러그인 설치 실패 (Claude Code 로그인 후 재시도)"
            }
        }
    }
    Install-ClaudePlugin "hookify"
    Install-ClaudePlugin "superpowers"
} else {
    Write-Warning "  claude 명령을 찾을 수 없어 플러그인 설치를 건너뜁니다."
}

# caveman: Claude Code 플러그인으로 설치 (출력 압축 ~75% 토큰 절감)
# irm|iex(non-TTY) 환경에서는 caveman 공식 install.ps1이 claude plugin install을 건너뛰므로
# 직접 claude plugin 명령어로 설치한다.
Write-Host "  > caveman 플러그인 설치 중... (JuliusBrussee/caveman)"
if (Get-Command claude -ErrorAction SilentlyContinue) {
    claude plugin marketplace add JuliusBrussee/caveman
    try {
        claude plugin install caveman@caveman
        Write-Host "  ✓ caveman 플러그인 설치 완료" -ForegroundColor Green
    } catch {
        Write-Warning "  ✗ caveman 설치 실패. 수동: claude plugin marketplace add JuliusBrussee/caveman; claude plugin install caveman@caveman"
    }
} else {
    Write-Host "  claude 명령을 찾을 수 없어 caveman 설치를 건너뜁니다." -ForegroundColor Yellow
}

# 8. PowerShell 7 프로필에 PSReadLine 자동완성 키 등록
# Tab → AcceptSuggestion (인라인 회색 제안 즉시 수락)
# RightArrow → TabCompleteNext (다음 후보로 이동)
# 주의: PowerShell 7 전용 프로필($PROFILE)에만 기록 → 5.1 세션은 영향 없음.
Write-Host "
[8/8] PowerShell 7 자동완성 키 바인딩 설정 중..." -ForegroundColor Yellow
$profilePath = $PROFILE
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
}
$profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
if ($profileContent -notmatch "AcceptSuggestion") {
    $bindBlock = @"

# === [setup_distribution] PSReadLine 자동완성 키 (PowerShell 7 전용) ===
if (`$PSVersionTable.PSVersion.Major -ge 7) {
    Set-PSReadLineKeyHandler -Key Tab -Function AcceptSuggestion
    Set-PSReadLineKeyHandler -Key RightArrow -Function TabCompleteNext
}
"@
    Add-Content -Path $profilePath -Value $bindBlock -Encoding utf8
    Write-Host "  ✓ Tab → AcceptSuggestion / RightArrow → TabCompleteNext 등록됨" -ForegroundColor Green
    Write-Host "    적용 위치: $profilePath" -ForegroundColor Gray
} else {
    Write-Host "  · 자동완성 키 바인딩 이미 등록됨" -ForegroundColor Gray
}

if ($profileContent -notmatch "function cc") {
    $ccBlock = @"

# === [setup_distribution] cc 단축 별칭: claude --dangerously-skip-permissions ===
function cc { claude --dangerously-skip-permissions @args }
"@
    Add-Content -Path $profilePath -Value $ccBlock -Encoding utf8
    Write-Host "  ✓ 'cc' 단축 명령 등록됨 (= claude --dangerously-skip-permissions)" -ForegroundColor Green
} else {
    Write-Host "  · 'cc' 단축 명령 이미 등록됨" -ForegroundColor Gray
}

Write-Host "
==========================================================" -ForegroundColor Green
Write-Host " 🎉 모든 필수 도구 설치가 완료되었습니다!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "
[다음 단계 안내]"
Write-Host "1. 'gemini' 또는 'claude' 명령어로 AI 대화를 시작하세요."
Write-Host "2. 'gws login' / 'clasp login' 으로 구글 워크스페이스 인증을 완료하세요."
Write-Host "3. 'firebase login' 으로 Firebase 인증을 완료하세요. (Firebase 사용 시)"
Write-Host "4. 'gh auth login' 으로 GitHub 인증을 완료하세요. (GitHub 저장소 사용 시)"
Write-Host "5. 새 PowerShell 7 창을 열어야 자동완성 키(Tab/→)가 적용됩니다."
Write-Host "6. Claude Code 안에서 '/teach-impeccable'을 실행해 디자인 스킬을 활성화하세요."
Write-Host "7. Claude 시작 후 '/mcp' 로 등록된 MCP 서버(playwright/context7/sequential-thinking/serena) 동작을 확인하세요."
Write-Host "8. 궁금한 점은 SNUG 온라인 오피스 채널에 문의해 주세요."
Write-Host "
아무 키나 누르면 창이 닫힙니다..."
pause
