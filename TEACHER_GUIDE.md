# 초보 선생님용 설치와 배포 안내

## 1) 이 저장소의 목적

이 저장소는 선생님이 AI 코딩 도구로 수업용 인터랙티브 웹사이트를 만들고 GitHub Pages에 공개할 수 있도록 컴퓨터를 준비해 줍니다. Git, GitHub CLI, Node.js, Claude Code 또는 AI 코딩 도구, GitHub 인증을 포함한 모든 도구를 한 번에 설치합니다.

## 2) 설치 전 준비

- GitHub 계정을 만듭니다.
- Claude, ChatGPT 등 사용할 AI 계정을 준비합니다.
- Windows는 PowerShell을 사용합니다.
- macOS는 Terminal을 사용합니다.
- public 저장소에 올릴 수 없는 자료가 무엇인지 미리 확인합니다.

## 3) 설치하기

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/bootstrap.ps1 | iex
```

macOS Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/tgtec26-crypto/snug-vibe-coding-setup/main/setup.sh | bash
```

설치가 중간에 실패해도 같은 명령을 다시 실행해도 됩니다.

## 4) 로그인하기

필수:

```bash
gh auth login
gh auth status
claude
```

추가 도구 로그인:

```bash
agy auth login
gws login
clasp login
firebase login
vercel login
supabase login
```

추가 도구는 실제로 쓰는 것만 로그인하면 됩니다.

## 5) 설치 확인하기

```bash
git --version
node --version
npm --version
gh --version
gh auth status
claude --version
```

버전 번호나 로그인 계정 정보가 보이면 정상입니다. `gh auth status`에서 로그인 정보가 보이지 않으면 `gh auth login`을 다시 실행합니다.

Git 사용자 정보도 확인합니다.

```bash
git config --global user.name
git config --global user.email
```

비어 있으면 설정합니다.

```bash
git config --global user.name "홍길동"
git config --global user.email "본인 GitHub 이메일"
```

## 6) 첫 웹사이트 실행하기

샘플 사이트 폴더로 이동합니다.

```bash
cd examples/basic-html-site
npx serve .
```

브라우저에 표시된 주소를 열면 OX 퀴즈가 실행됩니다. `index.html` 파일을 더블클릭해도 볼 수 있습니다.

## 7) GitHub 저장소 만들기

새 웹사이트 폴더를 만들고 `index.html`을 준비합니다.

```bash
mkdir my-class-site
cd my-class-site
```

저장소를 만들고 GitHub에 올립니다.

```bash
git init
git add .
git commit -m "첫 수업용 웹사이트 만들기"
gh repo create my-class-site --public --source=. --remote=origin --push
```

초급 연수에서는 public 저장소를 사용합니다.

## 8) GitHub Pages 켜기

GitHub 웹에서 다음 순서로 이동합니다.

1. Repository
2. Settings
3. Pages
4. Build and deployment
5. Source: `Deploy from a branch`
6. Branch: `main`
7. Folder: `/root`
8. Save

몇 분 뒤 Pages 주소가 만들어집니다.

## 9) 자주 나는 오류

### `gh` 인증 안 됨

```bash
gh auth login
gh auth status
```

두 명령을 다시 실행합니다.

### Git 사용자 이름/이메일 없음

`Author identity unknown` 오류가 나면 Git 사용자 정보를 설정합니다.

```bash
git config --global user.name "홍길동"
git config --global user.email "본인 GitHub 이메일"
```

### 저장소가 private이라 Pages가 안 켜짐

GitHub Free 계정에서는 private 저장소 Pages 사용이 제한될 수 있습니다. 연수용 저장소는 public으로 만듭니다.

### `index.html` 위치가 잘못됨

GitHub Pages 첫 화면은 보통 저장소 루트의 `index.html`을 사용합니다. `index.html`이 폴더 안에 있으면 Pages 설정의 Folder와 실제 위치가 맞는지 확인합니다.

### 배포 후 반영까지 시간이 걸림

GitHub Pages는 반영에 몇 분 걸릴 수 있습니다. Pages 화면에서 배포 상태를 확인하고 기다린 뒤 새로고침합니다.

## 보안 주의사항

- public 저장소에는 API 키를 올리지 않습니다.
- 학생 이름, 학번, 이메일, 성적, 출결 등 개인정보를 올리지 않습니다.
- 학교 내부 문서나 비공개 자료를 public 저장소에 올리지 않습니다.
- `.env` 파일은 public 저장소에 올리지 않습니다.
- GitHub Pages는 인터넷에 공개되는 웹사이트입니다.
