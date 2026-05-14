# SNUG 온라인 오피스 — 바이브 코딩 환경 설치 스크립트

서울대학교 사범대학 부설여자중학교(서울사대부여중) **SNUG 온라인 오피스**에서 동료 교사들이 AI 보조 코딩(Vibe Coding) 환경을 한 줄 명령어로 갖추도록 만든 자동 설치 스크립트입니다. **Windows·macOS** 모두 지원합니다.

---

## 빠른 설치

### Windows
**일반 PowerShell**(관리자 권한 불필요)을 실행한 후 아래 한 줄 입력:

```powershell
irm https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/bootstrap.ps1 | iex
```

### macOS
Terminal에서 아래 한 줄 입력:

```bash
curl -fsSL https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/setup.sh | bash
```

설치 시간: 인터넷 속도에 따라 5~15분 소요.

---

## 무엇이 설치되나요?

### 1. 시스템 패키지
| 도구 | 용도 |
|---|---|
| Node.js (LTS) | npm 글로벌 패키지 실행 환경 |
| Git | 버전 관리 |
| GitHub CLI (`gh`) | GitHub 저장소·PR·이슈 관리 |
| Python 3 | 일부 MCP 서버에서 사용 |
| Homebrew (Mac) | Mac 패키지 매니저 |
| jq (Mac) | JSON 파싱 |

### 2. AI 및 개발 CLI (npm 글로벌)
| 패키지 | 명령어 | 용도 |
|---|---|---|
| `@anthropic-ai/claude-code` | `claude` | Anthropic Claude AI CLI |
| `@google/gemini-cli` | `gemini` | Google Gemini AI CLI |
| `@googleworkspace/cli` | `gws` | Google Sheets/Drive 등 Workspace CLI |
| `@google/clasp` | `clasp` | Google Apps Script 도구 |
| `firebase-tools` | `firebase` | Firebase 인증·Firestore·배포 |
| `vercel` | `vercel` | Vercel 웹 배포 |
| `serve` | `serve` | 로컬 정적 서버 |
| `@playwright/test` | `playwright` | 웹 자동화·브라우저 테스트 |
| `xlsx` | — | 엑셀(.xlsx) 파일 처리 라이브러리 |
| `typescript` | `tsc` | TypeScript 컴파일러 |
| `tsx` | `tsx` | TypeScript 즉시 실행 도구 |

### 3. Claude Code 확장
- **MCP 서버**: `playwright`(브라우저 자동화), `context7`(라이브러리 공식 문서 검색), `sequential-thinking`(단계적 사고)
- **Skill**: `pbakaus/impeccable`(디자인 보조), `senior-frontend`(프론트엔드 코드 리뷰)
- **Playwright Chromium 브라우저** (약 150MB)

### 4. 셸 환경
- **Windows (PowerShell 7)**: `Tab` = 인라인 제안 수락, `→` = 다음 후보 이동
- **macOS (zsh)**: Tab 자동완성, `cc` 별칭(=`claude --dangerously-skip-permissions`)

---

## 설치 후 첫 단계

각 도구는 처음 한 번 인증이 필요합니다:

```bash
gh auth login         # GitHub
gemini                # Google 계정 로그인 안내가 표시됨
claude                # Anthropic 계정 로그인 안내가 표시됨
gws login             # Google Workspace
clasp login           # Google Apps Script
firebase login        # Firebase (사용 시)
```

---

## 동작 원리

### Windows
```
PowerShell
  └─ bootstrap.ps1                  (irm | iex 로 받아서 실행)
       ├─ setup.bat / setup.ps1 을 %TEMP%\snug-setup\ 로 다운로드
       └─ setup.bat 실행
            ├─ chcp 65001            (UTF-8 콘솔로 전환)
            ├─ pwsh.exe 호출         (PowerShell 7 우선, 없으면 5.1)
            └─ setup.ps1 본 설치 작업
```

> **왜 bootstrap이 필요한가?** Windows는 cmd → PowerShell 진입 시 코드페이지 전환이 필요하고, `setup.bat`이 그 역할을 담당합니다. `bootstrap.ps1`은 두 파일을 묶어 한 줄 명령어로 만들기 위한 진입점입니다.

### macOS
```
Terminal
  └─ setup.sh                       (curl | bash 로 직접 실행)
       └─ Homebrew + brew + npm 본 설치 작업
```

> Mac은 터미널이 기본 UTF-8이고 셸 환경이 일관적이라 중간 단계가 필요 없습니다.

---

## 파일 구성

| 파일 | 역할 |
|---|---|
| `bootstrap.ps1` | Windows 한 줄 명령어 진입점 (`irm \| iex` 패턴) |
| `setup.bat` | Windows cmd 진입점 (UTF-8 코드페이지 설정 + pwsh 호출) |
| `setup.ps1` | Windows 본 설치 스크립트 (8단계) |
| `setup.sh` | macOS 본 설치 스크립트 (8단계) |
| `.gitattributes` | `*.sh=lf` / `*.bat,*.ps1=crlf` 강제 (Mac bash 호환) |
| `README.md` | 본 문서 |

---

## 문제 해결

### `irm` 또는 `iex` 명령을 찾을 수 없습니다 (Windows)
PowerShell이 아닌 일반 cmd 창에서 실행한 경우입니다. 시작 메뉴 → "PowerShell" 검색 후 다시 시도하세요.

### "이 시스템에서 스크립트를 실행할 수 없으므로..." (Windows)
`bootstrap.ps1`은 내부적으로 `setup.bat`을 통해 `-ExecutionPolicy Bypass`로 실행되므로 정상 흐름에서는 발생하지 않습니다. 만약 발생하면 새 PowerShell 창에서 한 줄 명령어로 다시 실행하세요.

### Mac에서 `\r: command not found` 오류
`setup.sh`가 CRLF 줄바꿈으로 저장된 경우입니다. 본 저장소는 `.gitattributes`로 LF를 강제하므로 정상 다운로드 시 발생하지 않습니다. 발생 시:

```bash
sed -i '' 's/\r$//' setup.sh && bash setup.sh
```

### 한글이 깨져서 표시됨 (Windows)
- 한 줄 명령어로 실행한 경우: 자동으로 `chcp 65001`이 호출되므로 정상.
- `setup.ps1`만 직접 실행한 경우 발생 가능 → 항상 `setup.bat`(또는 한 줄 명령어)으로 시작하세요.

### 권한 부족으로 일부 패키지 설치 실패
- **Windows**: 새 PowerShell 창에서 한 줄 명령어로 다시 실행. winget이 UAC 프롬프트를 띄우면 "예"를 선택하세요. (관리자 권한으로 실행하면 scoop 설치가 우회 모드로 동작하므로 권장하지 않습니다.)
- **macOS**: 실패한 패키지를 `sudo npm install -g <패키지명>`로 개별 재시도

---

## 유지보수자용 메모

### 도구 추가/제거 시 절차
1. `setup.ps1`의 `$NPM_GLOBALS` 배열과 `setup.sh`의 `NPM_GLOBALS` 배열을 **양쪽 모두** 수정
2. MCP 서버 추가 시 `Add-Mcp`(ps1) / `add_mcp`(sh) 호출을 **양쪽 모두** 추가
3. 변경 후 커밋 + push:
   ```bash
   git add . && git commit -m "..." && git push
   ```
4. push 즉시 다음 사용자부터 한 줄 명령어로 자동 반영됨 (URL은 영구 동일)

### 줄바꿈 규칙 (중요)
- `*.sh` 파일은 **반드시 LF**로 저장. CRLF로 커밋되면 Mac bash가 `\r: command not found` 오류를 냄.
- `.gitattributes`가 자동으로 강제하지만, 외부 편집기 사용 시 주의.

### 마스터 작업 위치
- Windows 로컬 마스터: `C:\Users\user\agent\snug-vibe-coding-setup\`
- 그 외 위치(`G:\내 드라이브\GDagent\` 등)에 있는 사본은 참고용일 뿐 편집 대상이 아님.

---

## 문의

- 서울사대부여중 SNUG 온라인 오피스 채널
- 내부 배포용 스크립트입니다.
