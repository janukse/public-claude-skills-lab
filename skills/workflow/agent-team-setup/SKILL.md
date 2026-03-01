---
name: agent-team-setup
description: 에이전트 팀 사용을 위한 환경 진단, 추천 세팅, 자동 설정 워크플로우
argument-hint: "[--profile minimal|standard|full] [--display tmux|in-process]"
---

# Agent Team Setup

> **공식 문서**: https://code.claude.com/docs/ko/agent-teams
> 이 스킬은 공식 문서를 기반으로 환경을 진단하고 설정합니다. 최신 동작이 스킬과 다를 경우 공식 문서(`WebFetch`로 확인)를 우선합니다.

## 목적

에이전트 팀을 처음 사용하거나 새 프로젝트에서 팀 환경을 구성할 때, 필요한 설정을 진단하고 최적 구성을 추천한 뒤 자동으로 적용하는 워크플로우.

- 에이전트 팀에 필요한 환경변수, 도구, 권한 설정 상태를 한눈에 진단
- 프로젝트 규모와 사용 패턴에 맞는 추천 프로필 제공
- 승인 후 settings.json, 환경변수, 표시 모드 등 필요한 설정을 자동 적용
- 설정 완료 후 검증까지 수행

## 사용법

```
/agent-team-setup                          # 대화형으로 진단 + 추천 + 설정
/agent-team-setup --profile standard       # standard 프로필로 바로 설정
/agent-team-setup --display tmux           # 분할 창 표시 모드 포함 설정
/agent-team-setup --profile full --display tmux  # 전체 옵션 지정
```

### 옵션

| 옵션 | 설명 |
|------|------|
| `--profile <이름>` | 설정 프로필 지정 (`minimal`, `standard`, `full`). 생략 시 대화형으로 추천 |
| `--display <모드>` | 표시 모드 (`tmux`, `in-process`). 생략 시 자동 감지 |

## Workflow

### Step 0: 공식 문서 확인

`WebFetch`로 공식 문서를 조회하여 최신 설정 방법과 제한사항을 확인한다:

```
WebFetch:
  url: "https://code.claude.com/docs/ko/agent-teams"
  prompt: "에이전트 팀 활성화 방법, 표시 모드, 권한 설정, 제한사항을 추출해줘"
```

공식 문서에서 확인한 내용을 이후 단계의 기준으로 사용한다.

### Step 1: 환경 진단

현재 에이전트 팀 관련 설정 상태를 점검하여 진단 보고서를 생성한다.

#### 1a: 필수 항목 점검

다음 항목을 확인한다:

**환경변수:**
```bash
echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
```

**프로젝트 settings.json:**
- `.claude/settings.json` 파일 존재 여부 및 `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` 값 확인

**사용자 settings.json:**
- `~/.claude/settings.json` 파일의 동일 항목 확인

#### 1b: 선택 항목 점검

**분할 창 도구 (tmux / iTerm2):**
```bash
which tmux && tmux -V
echo $TMUX          # 비어있으면 tmux 세션 밖에서 실행 중
which it2            # iTerm2 CLI 설치 여부
echo $TERM_PROGRAM   # iTerm2 여부 확인
```

분할 창 판단 기준:
- `$TMUX` 값 있음 → tmux 분할 창 사용 가능
- `$TERM_PROGRAM` = `iTerm.app` + `it2` 설치됨 → iTerm2 분할 창 사용 가능
- 위 모두 해당 없음 → in-process 모드만 가능

> **참고**: 표시 모드 기본값은 `"auto"`. tmux 세션 안이면 자동으로 분할 창, 아니면 in-process. `teammateMode` 설정이나 `claude --teammate-mode` 플래그로 오버라이드 가능.

**CLAUDE.md 존재 여부:**
- 프로젝트 루트에 `CLAUDE.md`가 있는지 확인 (팀원들이 프로젝트 지침을 자동 로드하기 위해 필요)

**권한 설정 (`permissions.allow`):**
- `.claude/settings.json`의 `permissions.allow` 배열에 팀 관련 도구가 허용되어 있는지 확인
- 확인 대상: `Task`, `TeamCreate`, `TeamDelete`, `TaskCreate`, `TaskUpdate`, `TaskList`, `TaskGet`, `SendMessage`

#### 1c: 진단 결과 표시

```markdown
## 환경 진단 결과

| 항목 | 상태 | 설명 |
|------|------|------|
| 환경변수 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | OK/MISSING | 현재 값: ... |
| 프로젝트 settings.json | OK/MISSING/INCOMPLETE | 경로: .claude/settings.json |
| 분할 창 (tmux) | IN_SESSION/INSTALLED/NOT_INSTALLED | tmux 세션 내 여부 |
| 분할 창 (iTerm2) | AVAILABLE/NOT_AVAILABLE | it2 CLI + iTerm.app 여부 |
| CLAUDE.md | EXISTS/MISSING | 팀원 프로젝트 지침 공유용 |
| 도구 권한 (permissions.allow) | OK/PARTIAL/NOT_SET | 허용된 도구 수: N/8 |
| teammateMode 설정 | auto/tmux/in-process/NOT_SET | 현재 표시 모드 설정 |
```

상태 아이콘:
- `OK` — 설정 완료
- `MISSING` — 미설정 (설정 필요)
- `PARTIAL` — 일부만 설정됨
- `NOT_SET` — 기본값 사용 중

**모든 필수 항목이 OK이면** "이미 기본 설정이 완료되어 있습니다. 추가 최적화가 필요하면 --profile 옵션을 사용하세요."를 안내하고, `AskUserQuestion`으로 확인:
- "추가 최적화 진행" — Step 2로 이동
- "현재 상태로 충분" — 종료

### Step 2: 추천 프로필 선택

`--profile` 옵션이 지정되었으면 해당 프로필로 진행한다. 지정되지 않았으면 아래 기준으로 추천한다.

#### 프로필 정의

| 프로필 | 대상 | 설정 내용 |
|--------|------|-----------|
| **minimal** | 처음 사용, 테스트 목적 | 환경변수만 설정. 권한은 매번 수동 승인 |
| **standard** | 일반 프로젝트 (추천) | 환경변수 + 핵심 도구 권한 허용 + 표시 모드 설정 |
| **full** | 대규모/반복 사용 | 환경변수 + 전체 도구 권한 허용 + 표시 모드 설정 + hooks 안내 |

#### 각 프로필 상세

**minimal:**
```jsonc
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**standard:**
```jsonc
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": [
      "Task",
      "TeamCreate",
      "TeamDelete",
      "TaskCreate",
      "TaskUpdate",
      "TaskList",
      "TaskGet",
      "SendMessage"
    ]
  }
}
```

**full:**
```jsonc
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": [
      "Task",
      "TeamCreate",
      "TeamDelete",
      "TaskCreate",
      "TaskUpdate",
      "TaskList",
      "TaskGet",
      "SendMessage",
      "Bash(tmux *)",
      "Bash(which tmux*)"
    ]
  }
}
```

> **teammateMode 설정 (선택):** 사용자가 `--display` 옵션을 지정했거나 특정 표시 모드를 원하면, settings.json에 `"teammateMode"` 필드를 추가한다. 기본값 `"auto"`는 tmux 세션 안이면 분할 창, 아니면 in-process를 자동 선택한다.
> ```jsonc
> {
>   "teammateMode": "in-process"   // "auto" | "tmux" | "in-process"
> }
> ```

추천 결과를 표시한다:

```markdown
## 추천 프로필: <프로필명>

### 설정될 항목
| 항목 | 현재 | 변경 후 |
|------|------|---------|
| 환경변수 | <현재값> | 1 |
| permissions.allow | <현재 수> | <변경 후 수>개 |
| teammateMode | <현재> | <변경 후> |

### 이 프로필을 추천하는 이유
- <이유 1>
- <이유 2>
```

`AskUserQuestion`으로 확인:
- "이 프로필로 설정 (추천)" — Step 3으로 진행
- "다른 프로필 선택" — 프로필 목록에서 재선택
- "취소" — 종료

### Step 3: 설정 적용

선택된 프로필에 따라 설정을 적용한다.

#### 3a: settings.json 업데이트

기존 `.claude/settings.json`을 읽어서 프로필 설정을 **병합**한다. 기존 설정을 덮어쓰지 않고 추가/업데이트만 한다.

**병합 규칙:**
- `env` 객체: 기존 키 유지, 새 키 추가
- `permissions.allow` 배열: 기존 항목 유지, 새 항목만 추가 (중복 제거)
- `teammateMode`: 사용자가 지정한 경우에만 설정
- 기타 기존 설정: 그대로 유지

`Read`로 기존 파일을 읽고, 병합된 결과를 `Edit` 또는 `Write`로 적용한다.

#### 3b: 분할 창 확인 (--display tmux 또는 full 프로필)

분할 창 상태에 따라 분기한다:

**Case 1: tmux/iTerm2 모두 미설치**

```markdown
분할 창 도구가 설치되어 있지 않습니다. 에이전트 팀을 분할 창으로 모니터링하려면 다음 중 하나를 설치하세요.

**tmux 설치:**
- macOS: `brew install tmux`
- Ubuntu/Debian: `sudo apt install tmux`
- 플랫폼별 지침: https://github.com/tmux/tmux/wiki/Installing

**iTerm2 사용 (macOS):**
1. `it2` CLI 설치: https://github.com/mkusaka/it2
2. iTerm2 → Settings → General → Magic → Enable Python API 활성화

분할 창 없이도 in-process 모드로 에이전트 팀을 사용할 수 있습니다.
```

**Case 2: tmux 설치됨, 그러나 현재 tmux 세션 밖에서 실행 중 (`$TMUX` 비어있음)**

```markdown
tmux가 설치되어 있지만, 현재 tmux 세션 안에서 실행되고 있지 않습니다.

표시 모드 기본값은 `"auto"`:
- tmux 세션 안에서 Claude Code를 시작하면 → 자동으로 분할 창 모드
- tmux 세션 밖에서 시작하면 → 자동으로 in-process 모드

**분할 창을 사용하려면:**
tmux new -s claude    # 새 세션 생성
claude                # Claude Code 실행

**또는 iTerm2에서 (권장):**
tmux -CC              # iTerm2 네이티브 통합 모드

현재 상태에서는 in-process 모드로 에이전트 팀을 사용할 수 있습니다.
```

**Case 3: tmux 세션 내부 또는 iTerm2 사용 가능**

분할 창 사용 가능 상태를 확인하고 진행한다.

`AskUserQuestion`으로 확인:
- "분할 창 도구 설치 후 계속" — 설치 완료를 기다림 (Case 1)
- "tmux 세션에서 재시작" — 안내 후 종료 (Case 2)
- "in-process 모드로 계속" — 분할 창 없이 진행
- "취소" — 종료

#### 3c: 적용 결과 표시

```markdown
## 설정 적용 완료

### 변경된 파일
| 파일 | 변경 내용 |
|------|-----------|
| `.claude/settings.json` | env, permissions.allow 업데이트 |

### 적용된 설정
| 항목 | 값 |
|------|-----|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | 1 |
| `permissions.allow` | N개 도구 허용 |
| `teammateMode` | auto / tmux / in-process |
```

### Step 4: 설정 검증

적용된 설정이 정상인지 검증한다.

#### 4a: settings.json 유효성

`Read`로 `.claude/settings.json`을 다시 읽어 JSON 파싱이 정상인지 확인한다.

#### 4b: 환경변수 확인

```bash
echo $CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
```

**주의:** 프로젝트 settings.json에 `env`로 설정한 환경변수는 **다음 세션부터** 적용된다. 현재 세션에서 바로 사용하려면 셸에서 `export`가 필요할 수 있다.

#### 4c: 검증 결과

```markdown
## 설정 검증 결과

| 항목 | 결과 |
|------|------|
| settings.json JSON 유효성 | PASS/FAIL |
| 환경변수 활성화 | PASS/NEXT_SESSION |
| 도구 권한 설정 | PASS/PARTIAL |
| 분할 창 사용 가능 | PASS/SKIP |

모든 검증을 통과했습니다.
```

### Step 5: 사용 가이드 안내

설정이 완료된 후 바로 사용할 수 있도록 간단한 가이드를 제공한다.

```markdown
## 에이전트 팀 사용 준비 완료

### 바로 시작하기
/agent-team <작업 설명>

### 추천 사용 예시
- `/agent-team PR #42를 보안, 성능, 테스트 관점에서 병렬 리뷰해줘`
- `/agent-team 프론트엔드/백엔드/테스트 분리해서 작업해줘`
- `/agent-team --display tmux API 5개 병렬 구현`

### 표시 모드
- **in-process** (기본): 모든 터미널에서 작동. Shift+Down으로 팀원 순환.
- **분할 창**: tmux 세션 안에서 시작하거나, iTerm2에서 `tmux -CC`로 시작.
- 단일 세션: `claude --teammate-mode in-process`로 오버라이드 가능.

### 참고
- 현재 세션에서 환경변수가 인식되지 않으면, Claude Code를 재시작하세요
- 팀원 수는 3-5명이 권장됩니다 (비용 고려)
- `--plan-approval` 옵션으로 팀원의 계획을 사전 승인할 수 있습니다
- 분할 창은 VS Code 통합 터미널, Windows Terminal, Ghostty에서 미지원

### 공식 문서
https://code.claude.com/docs/ko/agent-teams
```

## 프로필 비교표

| 항목 | minimal | standard | full |
|------|---------|----------|------|
| 환경변수 설정 | O | O | O |
| 핵심 도구 권한 | X | O | O |
| tmux 관련 권한 | X | X | O |
| 사용자 확인 빈도 | 높음 (매번) | 낮음 | 최소 |
| 추천 대상 | 첫 사용자 | 일반 사용자 | 파워 유저 |
| 보안 수준 | 높음 | 중간 | 낮음 (모든 도구 허용) |

## 예외사항

### 이미 설정이 완료된 경우
모든 필수 항목이 이미 OK 상태이면 "이미 기본 설정이 완료되어 있습니다."를 안내하고, 추가 최적화 여부만 확인한 뒤 종료한다.

### settings.json이 없는 경우
`.claude/` 디렉토리나 `settings.json` 파일이 없으면 새로 생성한다. 디렉토리 생성 시 `.claude/` 경로를 사용한다.

### 기존 설정과 충돌
기존 `permissions.allow`에 이미 항목이 있으면 기존 항목을 유지하고 새 항목만 추가한다. 절대로 기존 설정을 제거하지 않는다.

### 권한 거부
사용자가 특정 도구 권한 추가를 거부하면 해당 항목만 건너뛰고 나머지를 적용한다.

## Related Files

| File | Purpose |
|------|---------|
| `.claude/settings.json` | 프로젝트별 에이전트 팀 설정 |
| `~/.claude/settings.json` | 사용자 전역 설정 |
| `.claude/skills/agent-team/SKILL.md` | 에이전트 팀 메인 스킬 (이 스킬로 설정 후 사용) |
| `CLAUDE.md` | 팀원들이 자동 로드하는 프로젝트 지침 |

## 참고 자료

- **공식 문서**: https://code.claude.com/docs/ko/agent-teams
- **권한 설정**: https://code.claude.com/docs/ko/permissions
- **Hooks**: https://code.claude.com/docs/ko/hooks (`TeammateIdle`, `TaskCompleted`)
- **Subagents 비교**: https://code.claude.com/docs/ko/sub-agents
- **비용**: https://code.claude.com/docs/ko/costs#agent-team-token-costs
