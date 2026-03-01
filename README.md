# Public Claude Skills Lab

Claude Code에서 사용할 수 있는 커스텀 스킬 모음입니다.

## 스킬 목록

### Development

| 스킬 | 설명 | 의존성 |
|------|------|--------|
| [code-convention](skills/development/code-convention/) | TS/JS 코드 컨벤션 Core 핵심 규칙(G1-G5). 네이밍, 타입, 함수, Import/Export, 에러 처리 가이드 및 검증 | - |
| [code-convention-quality](skills/development/code-convention-quality/) | 코드 품질 컨벤션(G6-G8). 주석/문서화, 테스트, Git/협업 규칙 가이드 및 검증 | code-convention |
| [code-convention-security](skills/development/code-convention-security/) | TS/JS 보안 컨벤션(G9). XSS, 입력 검증, 환경 변수, 민감 정보 보호 규칙 | code-convention |
| [code-convention-react](skills/development/code-convention-react/) | React Core 컨벤션(G1-G3). 컴포넌트, Hooks, 상태관리 핵심 규칙 | code-convention |
| [code-convention-react-patterns](skills/development/code-convention-react-patterns/) | React 패턴 컨벤션(G4-G7). 스타일링, 성능, 파일 구조, 보안 규칙 | code-convention, code-convention-react |
| [code-convention-vue3](skills/development/code-convention-vue3/) | Vue 3 Core 컨벤션(G1-G3). SFC, Composition API, Pinia 핵심 규칙 | code-convention |
| [code-convention-vue3-patterns](skills/development/code-convention-vue3-patterns/) | Vue 3 패턴 컨벤션(G4-G7). 디렉티브, Router, 파일 구조, 보안 규칙 | code-convention, code-convention-vue3 |
| [code-convention-node](skills/development/code-convention-node/) | Node.js Core 컨벤션(G1-G3). API 설계, 미들웨어, DB 핵심 규칙 | code-convention |
| [code-convention-node-ops](skills/development/code-convention-node-ops/) | Node.js 운영 컨벤션(G4-G6). 설정 관리, 로깅, 보안 규칙 | code-convention, code-convention-node |
| [prompt-craft](skills/development/prompt-craft/) | COSTAR+ 프레임워크 기반 프롬프트 설계. Generate/Improve/Evaluate 3모드 | - |

### Workflow

| 스킬 | 설명 | 의존성 |
|------|------|--------|
| [smart-commit](skills/workflow/smart-commit/) | 변경사항 분석 → 커밋 단위 분리 → 검증 → Conventional Commits 한국어 커밋 메시지 생성 | - |
| [skill-refactor](skills/workflow/skill-refactor/) | 길어진 스킬을 분석하여 분리 전략을 제안하고 리팩토링 | - |
| [doc-sync](skills/workflow/doc-sync/) | MD 문서와 코드베이스 불일치 감지, 수정안 제안 후 적용 | - |
| [agent-team](skills/workflow/agent-team/) | 에이전트 팀 생성 및 조율 워크플로우. 팀원 생성, 작업 분배, 모니터링, 종료까지 전체 라이프사이클 관리 | - |
| [agent-team-setup](skills/workflow/agent-team-setup/) | 에이전트 팀 사용을 위한 환경 진단, 추천 세팅, 자동 설정 워크플로우 | agent-team |
| [doc-review-panel](skills/workflow/doc-review-panel/) | 문서를 여러 페르소나(전문가 패널)가 각자의 관점에서 검토하고 종합 리포트 생성 | - |
| [design-workshop](skills/workflow/design-workshop/) | 범용 설계 워크플로우. 설계 유형 자동 감지, 전문가 패널 검토, ADR/설계 명세 문서 생성 | - |
| [task-completion-review](skills/workflow/task-completion-review/) | 작업 문서에서 항목 추출 후 코드베이스에서 실제 구현 완료 여부를 검증하여 리포트 생성 | - |

## 추천 조합

| 용도 | 설치할 스킬 |
|------|------------|
| **TS/JS 기본** | `code-convention` |
| **TS/JS 풀셋** | `code-convention` + `code-convention-quality` + `code-convention-security` |
| **React 개발** | `code-convention` + `code-convention-react` + `code-convention-react-patterns` |
| **Vue 3 개발** | `code-convention` + `code-convention-vue3` + `code-convention-vue3-patterns` |
| **Node.js 개발** | `code-convention` + `code-convention-node` + `code-convention-node-ops` |
| **풀스택 (React + Node)** | `code-convention` + `code-convention-react` + `code-convention-react-patterns` + `code-convention-node` + `code-convention-node-ops` + `code-convention-security` |
| **Git 워크플로우** | `smart-commit` |
| **프롬프트 엔지니어링** | `prompt-craft` |
| **문서 관리** | `doc-sync` |
| **에이전트 팀** | `agent-team` + `agent-team-setup` |
| **설계 워크숍** | `design-workshop` |
| **문서 리뷰** | `doc-review-panel` |
| **작업 검증** | `task-completion-review` |

## 설치 방법

### 방법 1: 수동 복사

원하는 스킬의 `SKILL.md` 파일을 프로젝트의 `.claude/skills/` 디렉토리에 복사합니다.

```bash
# 예: code-convention 스킬 설치
mkdir -p .claude/skills
cp skills/development/code-convention/SKILL.md .claude/skills/code-convention.md
```

의존성이 있는 스킬은 기본 스킬도 함께 복사해야 합니다.

```bash
# 예: React 개발 풀셋 설치
mkdir -p .claude/skills
cp skills/development/code-convention/SKILL.md .claude/skills/code-convention.md
cp skills/development/code-convention-react/SKILL.md .claude/skills/code-convention-react.md
cp skills/development/code-convention-react-patterns/SKILL.md .claude/skills/code-convention-react-patterns.md
```

### 방법 2: 설치 스크립트

```bash
# 저장소 클론
git clone https://github.com/janukse/public-claude-skills-lab.git
cd public-claude-skills-lab

# 인터랙티브 설치 (스킬 선택)
./install.sh

# 특정 조합 바로 설치
./install.sh --preset react    # React 개발 풀셋
./install.sh --preset vue3     # Vue 3 개발 풀셋
./install.sh --preset node     # Node.js 개발 풀셋
./install.sh --preset fullset  # TS/JS 풀셋
./install.sh --preset all      # 전체 설치

# 특정 스킬만 설치 (의존성 자동 해결)
./install.sh --skill code-convention-react
```

## 의존성 구조

```
code-convention (Core)
├── code-convention-quality
├── code-convention-security
├── code-convention-react
│   └── code-convention-react-patterns
├── code-convention-vue3
│   └── code-convention-vue3-patterns
└── code-convention-node
    └── code-convention-node-ops
```

## 라이선스

[MIT](LICENSE)
