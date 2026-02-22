#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# Public Claude Skills Lab - Installer
# ──────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
TARGET_DIR=".claude/skills"

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── 스킬 정의 ──────────────────────────────────

declare -A SKILL_PATH=(
  [code-convention]="development/code-convention"
  [code-convention-quality]="development/code-convention-quality"
  [code-convention-security]="development/code-convention-security"
  [code-convention-react]="development/code-convention-react"
  [code-convention-react-patterns]="development/code-convention-react-patterns"
  [code-convention-vue3]="development/code-convention-vue3"
  [code-convention-vue3-patterns]="development/code-convention-vue3-patterns"
  [code-convention-node]="development/code-convention-node"
  [code-convention-node-ops]="development/code-convention-node-ops"
  [smart-commit]="workflow/smart-commit"
  [skill-refactor]="workflow/skill-refactor"
)

declare -A SKILL_DEPS=(
  [code-convention]=""
  [code-convention-quality]="code-convention"
  [code-convention-security]="code-convention"
  [code-convention-react]="code-convention"
  [code-convention-react-patterns]="code-convention code-convention-react"
  [code-convention-vue3]="code-convention"
  [code-convention-vue3-patterns]="code-convention code-convention-vue3"
  [code-convention-node]="code-convention"
  [code-convention-node-ops]="code-convention code-convention-node"
  [smart-commit]=""
  [skill-refactor]=""
)

declare -A SKILL_DESC=(
  [code-convention]="TS/JS Core 규칙 (G1-G5)"
  [code-convention-quality]="코드 품질 규칙 (G6-G8)"
  [code-convention-security]="보안 규칙 (G9)"
  [code-convention-react]="React Core (G1-G3)"
  [code-convention-react-patterns]="React 패턴 (G4-G7)"
  [code-convention-vue3]="Vue 3 Core (G1-G3)"
  [code-convention-vue3-patterns]="Vue 3 패턴 (G4-G7)"
  [code-convention-node]="Node.js Core (G1-G3)"
  [code-convention-node-ops]="Node.js 운영 (G4-G6)"
  [smart-commit]="Conventional Commits 자동 커밋"
  [skill-refactor]="스킬 분석 및 리팩토링"
)

ALL_SKILLS=(
  code-convention code-convention-quality code-convention-security
  code-convention-react code-convention-react-patterns
  code-convention-vue3 code-convention-vue3-patterns
  code-convention-node code-convention-node-ops
  smart-commit skill-refactor
)

# ── 프리셋 ──────────────────────────────────

preset_react=(code-convention code-convention-react code-convention-react-patterns)
preset_vue3=(code-convention code-convention-vue3 code-convention-vue3-patterns)
preset_node=(code-convention code-convention-node code-convention-node-ops)
preset_fullset=(code-convention code-convention-quality code-convention-security)

# ── 함수 ──────────────────────────────────

resolve_deps() {
  local skill="$1"
  local -A seen=()
  local queue=("$skill")
  local result=()

  while [ ${#queue[@]} -gt 0 ]; do
    local current="${queue[0]}"
    queue=("${queue[@]:1}")

    if [[ -n "${seen[$current]:-}" ]]; then
      continue
    fi
    seen[$current]=1
    result+=("$current")

    local deps="${SKILL_DEPS[$current]:-}"
    if [[ -n "$deps" ]]; then
      for dep in $deps; do
        if [[ -z "${seen[$dep]:-}" ]]; then
          queue+=("$dep")
        fi
      done
    fi
  done

  echo "${result[@]}"
}

install_skill() {
  local skill="$1"
  local src="$SKILLS_DIR/${SKILL_PATH[$skill]}/SKILL.md"
  local dst="$TARGET_DIR/$skill.md"

  if [[ ! -f "$src" ]]; then
    echo -e "  ${RED}[ERROR]${NC} $skill: SKILL.md not found"
    return 1
  fi

  if [[ -f "$dst" ]]; then
    echo -e "  ${YELLOW}[SKIP]${NC}  $skill (already installed)"
    return 0
  fi

  cp "$src" "$dst"
  echo -e "  ${GREEN}[OK]${NC}    $skill"
}

install_skills() {
  local skills=("$@")
  local all_skills=()

  # 의존성 해결
  for skill in "${skills[@]}"; do
    local resolved
    resolved=$(resolve_deps "$skill")
    for s in $resolved; do
      local found=0
      for existing in "${all_skills[@]+"${all_skills[@]}"}"; do
        if [[ "$existing" == "$s" ]]; then
          found=1
          break
        fi
      done
      if [[ $found -eq 0 ]]; then
        all_skills+=("$s")
      fi
    done
  done

  # 의존성이 추가되었으면 알림
  if [[ ${#all_skills[@]} -gt ${#skills[@]} ]]; then
    echo -e "${CYAN}Dependencies resolved:${NC}"
    for s in "${all_skills[@]}"; do
      local is_dep=1
      for orig in "${skills[@]}"; do
        if [[ "$orig" == "$s" ]]; then
          is_dep=0
          break
        fi
      done
      if [[ $is_dep -eq 1 ]]; then
        echo -e "  ${BLUE}+ $s${NC} (dependency)"
      fi
    done
    echo ""
  fi

  mkdir -p "$TARGET_DIR"
  echo -e "${GREEN}Installing ${#all_skills[@]} skill(s) to $TARGET_DIR${NC}"
  echo ""

  for skill in "${all_skills[@]}"; do
    install_skill "$skill"
  done

  echo ""
  echo -e "${GREEN}Done!${NC}"
}

show_menu() {
  echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║   Public Claude Skills Lab - Installer       ║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
  echo ""
  echo "Available skills:"
  echo ""

  local i=1
  for skill in "${ALL_SKILLS[@]}"; do
    local deps="${SKILL_DEPS[$skill]:-}"
    local dep_info=""
    if [[ -n "$deps" ]]; then
      dep_info=" ${YELLOW}(requires: $deps)${NC}"
    fi
    printf "  ${BLUE}%2d${NC}) %-35s %s%b\n" "$i" "$skill" "${SKILL_DESC[$skill]}" "$dep_info"
    ((i++))
  done

  echo ""
  echo -e "${CYAN}Presets:${NC}"
  echo "  r) React     = code-convention + react + react-patterns"
  echo "  v) Vue 3     = code-convention + vue3 + vue3-patterns"
  echo "  n) Node.js   = code-convention + node + node-ops"
  echo "  f) TS/JS Full= code-convention + quality + security"
  echo "  a) All       = all skills"
  echo ""
  echo -n "Enter numbers (comma-separated) or preset letter: "
  read -r choice

  case "$choice" in
    r) install_skills "${preset_react[@]}" ;;
    v) install_skills "${preset_vue3[@]}" ;;
    n) install_skills "${preset_node[@]}" ;;
    f) install_skills "${preset_fullset[@]}" ;;
    a) install_skills "${ALL_SKILLS[@]}" ;;
    *)
      local selected=()
      IFS=',' read -ra nums <<< "$choice"
      for num in "${nums[@]}"; do
        num=$(echo "$num" | tr -d ' ')
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#ALL_SKILLS[@]} ]; then
          selected+=("${ALL_SKILLS[$((num-1))]}")
        else
          echo -e "${RED}Invalid selection: $num${NC}"
          exit 1
        fi
      done
      if [ ${#selected[@]} -eq 0 ]; then
        echo -e "${RED}No skills selected.${NC}"
        exit 1
      fi
      install_skills "${selected[@]}"
      ;;
  esac
}

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --preset <name>   Install a preset (react, vue3, node, fullset, all)"
  echo "  --skill <name>    Install a specific skill (with dependencies)"
  echo "  --target <dir>    Custom target directory (default: .claude/skills)"
  echo "  --list            List all available skills"
  echo "  -h, --help        Show this help"
  echo ""
  echo "Without options, runs interactive mode."
}

# ── 메인 ──────────────────────────────────

main() {
  if [[ $# -eq 0 ]]; then
    show_menu
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --preset)
        shift
        case "$1" in
          react)   install_skills "${preset_react[@]}" ;;
          vue3)    install_skills "${preset_vue3[@]}" ;;
          node)    install_skills "${preset_node[@]}" ;;
          fullset) install_skills "${preset_fullset[@]}" ;;
          all)     install_skills "${ALL_SKILLS[@]}" ;;
          *)       echo -e "${RED}Unknown preset: $1${NC}"; exit 1 ;;
        esac
        exit 0
        ;;
      --skill)
        shift
        if [[ -z "${SKILL_PATH[$1]:-}" ]]; then
          echo -e "${RED}Unknown skill: $1${NC}"
          exit 1
        fi
        install_skills "$1"
        exit 0
        ;;
      --target)
        shift
        TARGET_DIR="$1"
        ;;
      --list)
        echo "Available skills:"
        for skill in "${ALL_SKILLS[@]}"; do
          printf "  %-35s %s\n" "$skill" "${SKILL_DESC[$skill]}"
        done
        exit 0
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo -e "${RED}Unknown option: $1${NC}"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

main "$@"
