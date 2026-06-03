# SNUG 바이브코딩 초기 세팅 도구

웹사이트 제작 경험이 거의 없고 GitHub도 처음 사용하는 선생님이, AI 코딩 도구로 수업용 인터랙티브 웹사이트를 만들고 GitHub Pages에 공개할 수 있도록 준비하는 설치 저장소입니다.

## 이 저장소는 무엇인가?

- Windows와 macOS에서 기본 개발 도구를 설치합니다.
- GitHub 인증, Git 사용자 정보 설정, 첫 정적 웹사이트 실행, GitHub Pages 배포 흐름을 안내합니다.
- 초급 연수에서는 꼭 필요한 도구만 설치하고, 심화 도구는 선택으로 분리합니다.

## 누구를 위한 것인가?

- HTML/CSS/JavaScript를 처음 배우는 선생님
- GitHub 저장소와 GitHub Pages를 처음 사용하는 선생님
- Claude Code, ChatGPT, agy Antigravity CLI 같은 AI 도구로 수업 자료를 만들고 싶은 선생님

## 빠른 설치

설치가 중간에 실패해도 같은 명령어를 다시 실행해도 됩니다. 이미 설치된 항목은 건너뛰거나 업데이트되고, 실패한 항목만 다시 시도됩니다.

### Windows

PowerShell을 열고 실행합니다. 관리자 권한으로 시작하지 않아도 됩니다.

```powershell
irm https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/bootstrap.ps1 | iex
```

전체/심화 설치가 필요하면 먼저 환경 변수를 지정한 뒤 실행합니다.

```powershell
$env:SNUG_SETUP_MODE="full"
irm https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/bootstrap.ps1 | iex
```

### macOS

Terminal을 열고 실행합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/setup.sh | bash
```

전체/심화 설치가 필요하면 다음처럼 실행합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/setup.sh | bash -s -- --full
```

## 설치 전 확인

원격 스크립트를 실행하기 전에 내용을 먼저 확인할 수 있습니다.

Windows:

```powershell
irm https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/bootstrap.ps1
```

macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/setup.sh
```

내용을 확인한 뒤 위의 빠른 설치 명령을 실행합니다.

## 기본 설치 vs 전체 설치

초급 연수에서는 기본 설치만 사용해도 충분합니다.

| 구분 | 도구 | 설명 |
|---|---|---|
| 기본 설치 | Git | 파일 변경 기록, commit |
| 기본 설치 | GitHub CLI (`gh`) | GitHub 로그인, 저장소 생성, push |
| 기본 설치 | Node.js LTS / npm | 웹 개발 도구 실행 |
| 기본 설치 | Claude Code 또는 AI 코딩 도구 | AI에게 웹사이트 제작 요청 |
| 기본 설치 | `serve` | 만든 웹사이트를 내 컴퓨터에서 확인 |
| 선택 | Playwright | 브라우저 자동 테스트, 화면 확인 |
| 전체/심화 | `agy` | Google Antigravity CLI |
| 전체/심화 | `gws`, `clasp` | Google Workspace, Apps Script |
| 전체/심화 | `firebase-tools`, `vercel`, `supabase` | 백엔드/배포 심화 도구 |
| 전체/심화 | `xlsx`, `typescript`, `tsx` | 자료 처리와 TypeScript 개발 |
| 전체/심화 | MCP 관련 도구, agentmemory | Claude Code 확장 기능 |

## 설치 후 로그인

초급 연수 필수:

```bash
gh auth login
gh auth status
claude
```

- `gh auth login`: GitHub 계정으로 로그인합니다.
- `gh auth status`: GitHub 로그인이 되었는지 확인합니다.
- `claude`: Claude Code를 처음 실행하고 로그인합니다. 다른 AI 코딩 도구를 쓰는 경우 해당 도구의 로그인 절차를 따르면 됩니다.

선택/심화:

```bash
agy auth login
gws login
clasp login
firebase login
vercel login
supabase login
```

- `agy auth login`: agy Antigravity CLI 로그인
- `gws login`: Google Workspace CLI 로그인
- `clasp login`: Google Apps Script CLI 로그인
- `firebase login`: Firebase CLI 로그인
- `vercel login`: Vercel CLI 로그인
- `supabase login`: Supabase CLI 로그인

## 설치 확인

아래 명령이 버전 또는 인증 상태를 출력하면 정상입니다.

```bash
git --version
node --version
npm --version
gh --version
gh auth status
claude --version
```

성공 상태:

- `git --version`: `git version ...`이 보입니다.
- `node --version`: `v20...` 또는 그 이상의 LTS 버전이 보입니다.
- `npm --version`: 숫자 버전이 보입니다.
- `gh --version`: GitHub CLI 버전이 보입니다.
- `gh auth status`: 로그인한 GitHub 계정 정보가 보입니다.
- `claude --version`: Claude Code 버전이 보입니다.

## Git 사용자 정보 설정

처음 Git을 설치한 컴퓨터에서는 commit 전에 이름과 이메일을 설정해야 합니다. 설정이 없으면 `Author identity unknown` 오류가 납니다.

이미 설정되어 있는지 확인:

```bash
git config --global user.name
git config --global user.email
```

설정하기:

```bash
git config --global user.name "홍길동"
git config --global user.email "본인 GitHub 이메일"
```

GitHub 이메일은 GitHub 계정에 등록된 이메일을 사용합니다.

## 첫 웹사이트 실행하기

샘플 프로젝트가 들어 있습니다.

```bash
cd examples/basic-html-site
npx serve .
```

화면에 표시되는 주소를 브라우저에서 열면 OX 퀴즈 예제를 볼 수 있습니다. `index.html` 파일은 서버 없이 브라우저에서 바로 열어도 동작합니다.

## GitHub Pages 배포하기

새 수업용 웹사이트 폴더를 만들고 `index.html` 파일을 준비합니다.

```bash
mkdir my-class-site
cd my-class-site
```

`index.html` 파일을 만든 뒤 다음 명령을 실행합니다.

```bash
git init
git add .
git commit -m "첫 수업용 웹사이트 만들기"
gh repo create my-class-site --public --source=. --remote=origin --push
```

그 다음 GitHub 웹사이트에서 설정합니다.

1. Repository로 이동
2. Settings 클릭
3. Pages 클릭
4. Build and deployment에서 Source를 `Deploy from a branch`로 선택
5. Branch를 `main`, Folder를 `/root`로 선택
6. Save 클릭

주의:

- GitHub Free 계정에서는 private 저장소의 Pages 사용이 제한될 수 있습니다. 연수용 저장소는 `public`으로 만드세요.
- GitHub Pages는 인터넷에 공개되는 웹사이트입니다.
- API 키, 개인정보, 학생 정보, 학교 내부 자료를 public 저장소에 넣지 마세요.

## 자주 나는 오류

### `gh auth status`에서 로그인 안 됨

`gh auth login`을 다시 실행하고 GitHub 계정으로 로그인합니다.

### `Author identity unknown`

Git 사용자 이름과 이메일을 설정합니다.

```bash
git config --global user.name "홍길동"
git config --global user.email "본인 GitHub 이메일"
```

### GitHub Pages가 안 보임

저장소가 private인지 확인합니다. 초급 연수에서는 public 저장소를 사용합니다.

### Pages 주소로 들어갔는데 404가 보임

`index.html`이 저장소 루트에 있는지 확인합니다. 또는 Pages 설정에서 선택한 폴더와 실제 파일 위치가 맞는지 확인합니다.

### 배포 후 바로 반영되지 않음

GitHub Pages 반영에는 몇 분 정도 걸릴 수 있습니다. Pages 화면의 배포 상태를 확인한 뒤 다시 새로고침합니다.

## 보안 주의사항

- public 저장소에는 API 키를 올리지 않습니다.
- 학생 이름, 학번, 이메일, 성적, 출결 등 개인정보를 올리지 않습니다.
- 학교 내부 문서나 비공개 자료를 public 저장소에 올리지 않습니다.
- `.env` 파일은 public 저장소에 올리지 않습니다.
- GitHub Pages는 인터넷에 공개되는 웹사이트입니다.

## 제거 방법

모든 도구를 완벽히 지우는 절차는 운영체제와 설치 상태에 따라 다릅니다. 아래 명령으로 주요 도구를 제거할 수 있습니다.

Windows:

```powershell
winget uninstall Git.Git
winget uninstall GitHub.cli
winget uninstall OpenJS.NodeJS.LTS
npm uninstall -g @anthropic-ai/claude-code serve firebase-tools vercel @google/clasp @googleworkspace/cli
```

macOS:

```bash
brew uninstall git gh node
npm uninstall -g @anthropic-ai/claude-code vercel firebase-tools serve @google/clasp @googleworkspace/cli
```

## 개발자/관리자 참고

파일 구성:

| 파일 | 역할 |
|---|---|
| `bootstrap.ps1` | Windows 한 줄 설치 진입점 |
| `setup.bat` | Windows UTF-8 콘솔 설정 후 `setup.ps1` 실행 |
| `setup.ps1` | Windows 설치 스크립트 |
| `setup.sh` | macOS 설치 스크립트 |
| `TEACHER_GUIDE.md` | 초보 선생님용 단계별 안내 |
| `examples/basic-html-site/` | GitHub Pages용 단일 파일 HTML 예제 |

도구 추가/제거 시 `setup.ps1`과 `setup.sh`를 함께 수정하세요. macOS 스크립트는 LF 줄바꿈을 유지해야 합니다.
