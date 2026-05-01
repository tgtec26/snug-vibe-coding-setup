#!/usr/bin/env bash
# 🚦 [배포용] SNUG 온라인 오피스 바이브 코딩(AI 보조 코딩) 환경 설정 스크립트
# 작성일: 2026-04-12 (확장 개편: 2026-04-27)
# 용도: 동료 교사용 Claude / Gemini 기반 바이브 코딩 환경 자동 세팅 (macOS 전용)
# 호환: macOS Apple Silicon(M1+) / Intel 모두 지원
#
# 실행 방법:
#   1) 터미널에서 이 스크립트가 있는 폴더로 이동
#   2) chmod +x setup.sh   (최초 1회만)
#   3) ./setup.sh
#
# 주의: `set -e`는 의도적으로 사용하지 않음 — 한 패키지 설치 실패가
#       전체 설치를 중단시키지 않도록 각 단계마다 개별적으로 오류를 처리한다.

# === ANSI 색상 유틸 ===
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
GRAY=$'\033[0;90m'
NC=$'\033[0m'

# === macOS 환경 확인 ===
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "${RED}이 스크립트는 macOS 전용입니다. Windows에서는 setup_distribution.ps1(.bat) 을 사용하세요.${NC}"
  exit 1
fi

echo "${CYAN}==========================================================${NC}"
echo "${CYAN}    SNUG 온라인 오피스 바이브 코딩 환경 설치를 시작합니다${NC}"
echo "${CYAN}==========================================================${NC}"

# ============================================================
# 1. 셸 / Homebrew 점검
# ============================================================
echo ""
echo "${YELLOW}[1/8] 셸 환경 / Homebrew 점검 중...${NC}"
echo "  ✓ 셸: $SHELL"
echo "  ✓ macOS: $(sw_vers -productVersion 2>/dev/null || echo unknown)"

# Apple Silicon / Intel 양쪽의 brew 경로를 PATH에 노출
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew &>/dev/null; then
  echo "  ${YELLOW}· Homebrew 미설치. 자동 설치를 시도합니다... (관리자 비밀번호가 필요할 수 있습니다)${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # 설치 직후 PATH 갱신
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if ! command -v brew &>/dev/null; then
  echo "  ${RED}✗ Homebrew 설치에 실패했습니다.${NC}"
  echo "    ${CYAN}https://brew.sh 에서 수동 설치 후 다시 실행해 주세요.${NC}"
  exit 1
fi
echo "  ${GREEN}✓ Homebrew $(brew --version | head -n1) 확인됨${NC}"

# ============================================================
# 2. Node.js 및 npm 설치 확인 (없으면 brew로 자동 설치)
# ============================================================
echo ""
echo "${YELLOW}[2/8] 필수 엔진(Node.js) 점검 중...${NC}"
if ! command -v npm &>/dev/null; then
  echo "  Node.js 미설치. brew로 자동 설치를 시도합니다..."
  brew install node
fi
if ! command -v npm &>/dev/null; then
  echo "  ${RED}✗ Node.js 자동 설치에 실패했습니다.${NC}"
  echo "    ${CYAN}https://nodejs.org/ 에서 'LTS 버전'을 수동 설치하고 다시 실행해 주세요.${NC}"
  exit 1
fi
NODE_VER=$(node --version 2>/dev/null)
echo "  ${GREEN}✓ Node.js ${NODE_VER} 확인되었습니다.${NC}"

# ============================================================
# 3. 보조 도구(Git / 코드 에디터 / Python / gh / jq) 점검 및 자동 설치
# ============================================================
echo ""
echo "${YELLOW}[3/8] 보조 도구(Git / 에디터 / Python / gh / jq / OpenJDK / pipx / opendataloader-pdf / uv / serena) 점검 중...${NC}"

# Git: 버전 관리 / GitHub 연동에 필수 — 미설치 시 brew로 자동 설치
if command -v git &>/dev/null; then
  echo "  ${GREEN}✓ Git 확인됨 ($(git --version))${NC}"
else
  echo "  · Git 미설치. brew로 자동 설치를 시도합니다..."
  if brew install git; then
    echo "  ${GREEN}✓ Git 설치 완료${NC}"
  else
    echo "  ${YELLOW}✗ Git 자동 설치 실패. 수동 설치: https://git-scm.com/download/mac${NC}"
  fi
fi

# 코드 에디터: VS Code 또는 Cursor 권장
EDITOR_FOUND=false
if command -v code &>/dev/null || [[ -d "/Applications/Visual Studio Code.app" ]]; then
  echo "  ${GREEN}✓ Visual Studio Code 확인됨${NC}"
  EDITOR_FOUND=true
fi
if command -v cursor &>/dev/null || [[ -d "/Applications/Cursor.app" ]]; then
  echo "  ${GREEN}✓ Cursor 확인됨${NC}"
  EDITOR_FOUND=true
fi
if ! $EDITOR_FOUND; then
  echo "  ${YELLOW}✗ 코드 에디터가 감지되지 않았습니다.${NC}"
  echo "    ${CYAN}VS Code(권장):    https://code.visualstudio.com/${NC}"
  echo "    ${CYAN}Cursor(AI 편집기): https://cursor.com/${NC}"
  echo "    ${CYAN}또는 brew:        brew install --cask visual-studio-code${NC}"
fi

# Python: 일부 AI 도구·MCP 서버에서 사용
if command -v python3 &>/dev/null; then
  echo "  ${GREEN}✓ Python 확인됨 ($(python3 --version))${NC}"
else
  echo "  ${GRAY}· Python3는 감지되지 않았지만 필수는 아닙니다. (필요 시 'brew install python')${NC}"
fi

# GitHub CLI(gh): GitHub 저장소·PR·이슈 관리 — 별도 설치
if command -v gh &>/dev/null; then
  GH_LINE=$(gh --version 2>/dev/null | head -n1)
  echo "  ${GREEN}✓ GitHub CLI 확인됨 (${GH_LINE})${NC}"
else
  echo "  · GitHub CLI(gh) 미설치. brew로 자동 설치를 시도합니다..."
  if brew install gh; then
    echo "  ${GREEN}✓ GitHub CLI(gh) 설치 완료. 'gh auth login' 으로 인증하세요.${NC}"
  else
    echo "  ${YELLOW}✗ gh 자동 설치 실패. 수동 설치: https://cli.github.com/${NC}"
  fi
fi

# jq: JSON 처리 (gws 출력 파싱 등에 사용)
if command -v jq &>/dev/null; then
  echo "  ${GREEN}✓ jq 확인됨 ($(jq --version))${NC}"
else
  echo "  · jq 미설치. brew로 자동 설치를 시도합니다..."
  if brew install jq; then
    echo "  ${GREEN}✓ jq 설치 완료${NC}"
  else
    echo "  ${YELLOW}✗ jq 자동 설치 실패. 수동 설치: https://jqlang.github.io/jq/download/${NC}"
  fi
fi

# OpenJDK: Java 런타임 (PDF 변환 도구 opendataloader-pdf 등에 필요)
if command -v java &>/dev/null; then
  echo "  ${GREEN}✓ Java(OpenJDK) 확인됨 ($(java -version 2>&1 | head -n1))${NC}"
else
  echo "  · OpenJDK 미설치. brew로 자동 설치를 시도합니다..."
  if brew install openjdk; then
    # keg-only 이므로 셸 PATH에 즉시 노출 (영구 등록은 [8/8] 셸 환경 단계에서 처리)
    if [[ -d /opt/homebrew/opt/openjdk/bin ]]; then
      export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    elif [[ -d /usr/local/opt/openjdk/bin ]]; then
      export PATH="/usr/local/opt/openjdk/bin:$PATH"
    fi
    echo "  ${GREEN}✓ OpenJDK 설치 완료${NC}"
  else
    echo "  ${YELLOW}✗ OpenJDK 자동 설치 실패. 수동: brew install openjdk${NC}"
  fi
fi

# pipx: 격리된 Python CLI 도구 설치 (opendataloader-pdf 등)
if command -v pipx &>/dev/null; then
  echo "  ${GREEN}✓ pipx 확인됨 ($(pipx --version))${NC}"
else
  echo "  · pipx 미설치. brew로 자동 설치를 시도합니다..."
  if brew install pipx; then
    pipx ensurepath >/dev/null 2>&1 || true
    echo "  ${GREEN}✓ pipx 설치 완료${NC}"
  else
    echo "  ${YELLOW}✗ pipx 자동 설치 실패. 수동: brew install pipx${NC}"
  fi
fi

# opendataloader-pdf: PDF → Markdown/JSON 변환 CLI (내부적으로 Java 11+ 사용)
if command -v opendataloader-pdf &>/dev/null; then
  echo "  ${GREEN}✓ opendataloader-pdf 확인됨${NC}"
elif command -v pipx &>/dev/null; then
  echo "  · opendataloader-pdf 미설치. pipx로 설치를 시도합니다..."
  if pipx install opendataloader-pdf; then
    echo "  ${GREEN}✓ opendataloader-pdf 설치 완료${NC}"
  else
    echo "  ${YELLOW}✗ opendataloader-pdf 설치 실패. 수동: pipx install opendataloader-pdf${NC}"
  fi
else
  echo "  ${GRAY}· pipx가 없어 opendataloader-pdf 설치를 건너뜁니다.${NC}"
fi

# uv: 빠른 Python 패키지 매니저 (Serena 등 Python 기반 MCP/도구 설치에 사용)
if command -v uv &>/dev/null; then
  echo "  ${GREEN}✓ uv 확인됨 ($(uv --version))${NC}"
else
  echo "  · uv 미설치. brew로 자동 설치를 시도합니다..."
  if brew install uv; then
    echo "  ${GREEN}✓ uv 설치 완료${NC}"
  else
    echo "  ${YELLOW}✗ uv 자동 설치 실패. 수동: brew install uv${NC}"
  fi
fi

# serena: 코드베이스 시맨틱 분석 MCP 서버 (uv tool 로 격리 설치)
# 공식 권장: 마켓플레이스 설치 금지 → 반드시 uv tool install 경로 사용
if command -v serena &>/dev/null; then
  echo "  ${GREEN}✓ serena 확인됨${NC}"
elif command -v uv &>/dev/null; then
  echo "  · serena 미설치. uv tool 로 설치를 시도합니다..."
  if uv tool install -p 3.13 serena-agent@latest --prerelease=allow; then
    echo "  ${GREEN}✓ serena 설치 완료${NC}"
  else
    echo "  ${YELLOW}✗ serena 설치 실패. 수동: uv tool install -p 3.13 serena-agent@latest --prerelease=allow${NC}"
  fi
else
  echo "  ${GRAY}· uv가 없어 serena 설치를 건너뜁니다.${NC}"
fi

# ============================================================
# 4. 인공지능 및 개발 도구 자동 설치 (Global npm Packages)
# ============================================================
echo ""
echo "${YELLOW}[4/8] 인공지능 / 개발 CLI 도구 설치 및 업데이트 중 (잠시만 기다려 주세요)...${NC}"

NPM_GLOBALS=(
  "@google/gemini-cli@latest"          # Gemini AI CLI (gemini)
  "@anthropic-ai/claude-code@latest"   # Claude Code AI CLI (claude)
  "@googleworkspace/cli@latest"        # gws — Google Sheets/Drive 등 Workspace CLI
  "@google/clasp@latest"               # Google Apps Script 도구 (clasp)
  "firebase-tools@latest"              # Firebase 인증·Firestore·배포 (firebase)
  "vercel@latest"                      # Vercel 웹 배포 (vercel)
  "serve@latest"                       # 로컬 정적 서버 (serve)
  "@playwright/test@latest"            # 웹 자동화·브라우저 테스트
  "xlsx@latest"                        # 엑셀(.xlsx) 파일 처리 라이브러리
  "typescript@latest"                  # TypeScript 컴파일러 (tsc)
  "tsx@latest"                         # TypeScript 즉시 실행 도구 (tsx)
)

for pkg in "${NPM_GLOBALS[@]}"; do
  echo "  > $pkg 설치 중..."
  if npm install -g "$pkg" --silent 2>/dev/null; then
    echo "    ${GRAY}- $pkg 설치 성공${NC}"
  else
    echo "    ${YELLOW}- $pkg 설치 중 오류 발생 (이미 설치되어 있거나 권한 문제일 수 있음)${NC}"
    echo "    ${GRAY}  필요 시: sudo npm install -g $pkg${NC}"
  fi
done

# ============================================================
# 5. Playwright 브라우저 바이너리 설치 (웹 자동화·스크린샷용)
# ============================================================
echo ""
echo "${YELLOW}[5/8] Playwright 브라우저(Chromium) 설치 중...${NC}"
echo "  ${GRAY}(웹 자동화/스크린샷에 사용. 약 150MB 다운로드)${NC}"
if npx --yes playwright install chromium; then
  echo "  ${GREEN}✓ Playwright 브라우저 설치 완료${NC}"
else
  echo "  ${YELLOW}✗ Playwright 브라우저 설치 중 오류가 발생했습니다.${NC}"
fi

# ============================================================
# 6. Claude Code MCP 서버 추가 (Claude의 능력을 확장하는 외부 도구들)
# ============================================================
echo ""
echo "${YELLOW}[6/8] Claude Code MCP 서버 추가 중...${NC}"

if command -v claude &>/dev/null; then
  MCP_LIST=$(claude mcp list 2>/dev/null || echo "")

  add_mcp() {
    local name="$1"
    local cmd="$2"
    local desc="$3"
    if echo "$MCP_LIST" | grep -q -- "$name"; then
      echo "  ${GRAY}· MCP $name : 이미 등록됨 ($desc)${NC}"
    else
      echo "  > MCP $name 등록 중... ($desc)"
      # shellcheck disable=SC2086
      if claude mcp add "$name" -- $cmd >/dev/null 2>&1; then
        echo "    ${GREEN}✓ $name 등록 완료${NC}"
      else
        echo "    ${YELLOW}✗ $name 등록 실패${NC}"
      fi
    fi
  }

  add_mcp "playwright"           "npx @playwright/mcp@latest"                              "브라우저 자동화/스크린샷"
  add_mcp "context7"             "npx -y @upstash/context7-mcp"                            "라이브러리 공식 문서 검색"
  add_mcp "sequential-thinking"  "npx -y @modelcontextprotocol/server-sequential-thinking" "단계적 사고 도구"
  add_mcp "serena"               "serena start-mcp-server --context claude-code --project-from-cwd" "코드베이스 시맨틱 분석"
else
  echo "  ${YELLOW}claude 명령을 찾을 수 없어 MCP 등록을 건너뜁니다. (Claude Code 설치 후 재실행)${NC}"
fi

# ============================================================
# 7. Claude Code 디자인·프론트엔드 스킬 추가
# pbakaus/impeccable: 디자인 보조 스킬 모음 (frontend-design, polish, delight, animate, audit 등)
# senior-frontend: 시니어 프론트엔드 엔지니어 관점의 코드 리뷰/제안 스킬
# ============================================================
echo ""
echo "${YELLOW}[7/8] Claude Code 추가 스킬·플러그인(impeccable / senior-frontend / hookify / superpowers) 설치 중...${NC}"
echo "  ${GRAY}(UI/UX 품질·프론트엔드 코드 품질 + AI 행동 hook 관리 + 워크플로우 자동화)${NC}"

if npx --yes skills add pbakaus/impeccable; then
  echo "  ${GREEN}✓ impeccable 스킬 설치 완료${NC}"
else
  echo "  ${YELLOW}✗ impeccable 스킬 설치 실패 (Claude Code 로그인 후 재시도)${NC}"
fi

SKILL_ROOT="$HOME/.claude/skills"
if [[ -d "$SKILL_ROOT/senior-frontend" ]]; then
  echo "  ${GRAY}· senior-frontend 스킬 이미 존재${NC}"
else
  if npx -y claude-code-templates@latest --skill development/senior-frontend; then
    echo "  ${GREEN}✓ senior-frontend 스킬 설치 완료${NC}"
  else
    echo "  ${YELLOW}✗ senior-frontend 스킬 설치 실패${NC}"
  fi
fi

# Claude Code 공식 마켓플레이스 플러그인 (anthropics/claude-plugins-official)
# - hookify    : 대화 분석/명시적 지시로부터 AI 행동 hook 자동 생성·관리
# - superpowers: 브레인스토밍/계획/TDD/디버깅 등 워크플로우 자동화 스킬 모음
if command -v claude &>/dev/null; then
  CLAUDE_PLUGIN_LIST=$(claude plugin list 2>/dev/null || echo "")

  install_claude_plugin() {
    local name="$1"
    if echo "$CLAUDE_PLUGIN_LIST" | grep -q "${name}@"; then
      echo "  ${GRAY}· ${name} 플러그인 이미 설치됨${NC}"
    else
      echo "  > ${name} 플러그인 설치 중..."
      if claude plugin install "${name}@claude-plugins-official" >/dev/null 2>&1; then
        echo "  ${GREEN}✓ ${name} 플러그인 설치 완료${NC}"
      else
        echo "  ${YELLOW}✗ ${name} 플러그인 설치 실패 (Claude Code 로그인 후 재시도)${NC}"
      fi
    fi
  }

  install_claude_plugin "hookify"
  install_claude_plugin "superpowers"
else
  echo "  ${YELLOW}claude 명령을 찾을 수 없어 플러그인 설치를 건너뜁니다.${NC}"
fi

# ============================================================
# 8. macOS 셸 환경 설정 (zsh 자동완성 + cc 별칭 + Karabiner 안내)
#    - PowerShell 7의 PSReadLine 키 바인딩에 해당하는 macOS 측 설정
# ============================================================
echo ""
echo "${YELLOW}[8/8] macOS 셸 환경 설정 (zsh 자동완성 / cc 별칭 / Karabiner 안내)...${NC}"

# 셸 RC 파일 결정 (zsh 우선)
SHELL_RC="$HOME/.zshrc"
[[ "$SHELL" == */bash* ]] && SHELL_RC="$HOME/.bashrc"
touch "$SHELL_RC"

# (1) cc 별칭: claude --dangerously-skip-permissions 단축
if grep -q "alias cc=" "$SHELL_RC" 2>/dev/null; then
  echo "  ${GRAY}· alias cc 이미 등록됨${NC}"
else
  {
    echo ""
    echo "# === [setup.sh] Claude Code 단축 별칭 ==="
    echo "alias cc='claude --dangerously-skip-permissions'"
  } >> "$SHELL_RC"
  echo "  ${GREEN}✓ alias cc 등록됨 ($SHELL_RC)${NC}"
fi

# (1-2) OpenJDK PATH 영구 등록 (keg-only 이므로 brew가 자동으로 PATH에 넣지 않음)
if grep -q "openjdk/bin" "$SHELL_RC" 2>/dev/null; then
  echo "  ${GRAY}· OpenJDK PATH 이미 등록됨${NC}"
else
  if [[ -d /opt/homebrew/opt/openjdk/bin ]]; then
    {
      echo ""
      echo "# === [setup.sh] OpenJDK PATH (opendataloader-pdf 등 Java 도구용) ==="
      echo 'export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"'
    } >> "$SHELL_RC"
    echo "  ${GREEN}✓ OpenJDK PATH 등록됨 (Apple Silicon)${NC}"
  elif [[ -d /usr/local/opt/openjdk/bin ]]; then
    {
      echo ""
      echo "# === [setup.sh] OpenJDK PATH (opendataloader-pdf 등 Java 도구용) ==="
      echo 'export PATH="/usr/local/opt/openjdk/bin:$PATH"'
    } >> "$SHELL_RC"
    echo "  ${GREEN}✓ OpenJDK PATH 등록됨 (Intel)${NC}"
  else
    echo "  ${GRAY}· OpenJDK 미설치 상태 — PATH 등록 건너뜀${NC}"
  fi
fi

# (2) zsh 자동완성 (Tab 키 동작)
if [[ "$SHELL_RC" == *".zshrc" ]]; then
  if grep -q "setup.sh] zsh 자동완성" "$SHELL_RC" 2>/dev/null; then
    echo "  ${GRAY}· zsh 자동완성 설정 이미 등록됨${NC}"
  else
    cat >> "$SHELL_RC" <<'ZSHEOF'

# === [setup.sh] zsh 자동완성 설정 ===
# 제안이 있을 때 Tab 으로 즉시 수락, 없을 때는 기본 완성 동작 수행
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
ZSHEOF
    echo "  ${GREEN}✓ zsh 자동완성 설정 추가됨${NC}"
  fi
fi

# (3) Karabiner-Elements: Cmd+V → Ctrl+V 변환 (gemini/claude 실행 시 이미지 첨부용)
if [[ -d "$HOME/.config/karabiner" ]]; then
  echo "  ${GREEN}✓ Karabiner-Elements 설정 폴더 확인됨${NC}"
  echo "    ${GRAY}이미지 첨부 단축키(Cmd+V→Ctrl+V) 매핑 파일은 Karabiner 앱에서 직접 활성화하세요.${NC}"
  echo "    ${GRAY}경로: ~/.config/karabiner/assets/complex_modifications/${NC}"
else
  echo "  ${YELLOW}· Karabiner-Elements 미설치.${NC}"
  echo "    ${GRAY}터미널(Warp/Ghostty)에서 Cmd+V로 이미지 첨부를 사용하려면 설치 권장:${NC}"
  echo "    ${CYAN}brew install --cask karabiner-elements${NC}"
fi

# ============================================================
# 완료
# ============================================================
echo ""
echo "${GREEN}==========================================================${NC}"
echo "${GREEN} 🎉 모든 필수 도구 설치가 완료되었습니다!${NC}"
echo "${GREEN}==========================================================${NC}"
echo ""
echo "[다음 단계 안내]"
echo "1. 'gemini' 또는 'claude' 명령어로 AI 대화를 시작하세요."
echo "   (또는 'cc' — claude 권한 스킵 모드 단축키)"
echo "2. 'gws login' / 'clasp login' 으로 구글 워크스페이스 인증을 완료하세요."
echo "3. 'firebase login' 으로 Firebase 인증을 완료하세요. (Firebase 사용 시)"
echo "4. 'gh auth login' 으로 GitHub 인증을 완료하세요. (GitHub 저장소 사용 시)"
echo "5. 새 터미널 창을 열어야 alias cc / 자동완성 설정이 적용됩니다."
echo "   ${CYAN}또는 즉시 적용: source $SHELL_RC${NC}"
echo "6. Claude Code 안에서 '/teach-impeccable'을 실행해 디자인 스킬을 활성화하세요."
echo "7. Claude 시작 후 '/mcp' 로 등록된 MCP 서버(playwright/context7/sequential-thinking/serena) 동작을 확인하세요."
echo "8. 궁금한 점은 SNUG 온라인 오피스 채널에 문의해 주세요."
echo ""
