---
name: design-workshop
description: 범용 소프트웨어 설계 워크플로우. 설계 유형 자동 감지, 전문가 패널 검토, 단계별 가이드, 설계 문서 생성, feature-planner 연계 지원
argument-hint: "<설계 주제> [--type architecture|api|database|uiux|system] [--with-plan] [--parallel]"
---

# Design Workshop

## 목적

소프트웨어 설계를 체계적으로 진행하기 위한 범용 워크플로우. 요구사항 분석부터 설계 문서 생성까지 전문가 패널의 다관점 검토를 포함한 단계별 설계 프로세스를 제공한다.

- 설계 유형(아키텍처, API, DB, UI/UX, 시스템)을 자동 감지하고 유형에 맞는 설계 템플릿 적용
- 설계 유형별 전문가 페르소나가 다각도로 설계를 검토하여 맹점 제거
- 요구사항 분석 → 설계 초안 → 패널 검토 → 확정 → 문서화의 체계적 워크플로우
- ADR(Architecture Decision Record) 및 설계 명세서 등 표준 형식 문서 자동 생성
- feature-planner 스킬과 연계하여 설계 결과 기반 작업 지시서(plan) 자동 생성 지원

## 사용법

```
/design-workshop 사용자 인증 시스템 재설계
/design-workshop REST API v2 설계 --type api
/design-workshop 주문 도메인 DB 스키마 설계 --type database --adr
/design-workshop 대시보드 컴포넌트 설계 --type uiux --personas "UI 디자이너, 프론트엔드 시니어, 접근성 전문가"
/design-workshop 알림 시스템 아키텍처 --preset arch --parallel --with-plan
/design-workshop 결제 모듈 설계 --output docs/designs/payment/ --adr --with-plan
```

### 옵션

| 옵션 | 설명 |
|------|------|
| `<설계 주제>` | 설계할 기능 또는 시스템 설명 (필수) |
| `--type <유형>` | 설계 유형 강제 지정: `architecture`, `api`, `database`, `uiux`, `system` |
| `--personas "A, B, C"` | 쉼표로 구분한 커스텀 검토 페르소나 목록 |
| `--preset <이름>` | 프리셋 검토 패널 사용 (아래 표 참고) |
| `--parallel` | 에이전트 팀을 사용한 병렬 검토 (기본: 순차) |
| `--with-plan` | 설계 완료 후 feature-planner로 작업 지시서 자동 생성 |
| `--output <경로>` | 설계 문서 저장 경로 (기본: `docs/designs/`) |
| `--adr` | ADR(Architecture Decision Record) 문서도 함께 생성 |

### 프리셋 검토 패널

| 프리셋 | 페르소나 구성 | 적합한 설계 |
|--------|--------------|-------------|
| `arch` | 시스템 아키텍트, 보안 전문가, DevOps 엔지니어, 성능 엔지니어 | 시스템/서비스 아키텍처 설계 |
| `api` | API 설계 전문가, 프론트엔드 소비자, 보안 전문가, DX 엔지니어 | REST/GraphQL API 설계 |
| `db` | DBA, 데이터 모델러, 백엔드 엔지니어, 성능 전문가 | DB 스키마, 데이터 모델 설계 |
| `frontend` | UI/UX 디자이너, 프론트엔드 시니어, 접근성 전문가, 성능 전문가 | UI 컴포넌트, 화면 설계 |
| `fullstack` | 풀스택 시니어, 보안 전문가, DevOps 엔지니어, QA 리드 | 전체 기능 통합 설계 |

## Workflow

### Step 1: 요구사항 분석

#### 1a: 설계 주제 파악

사용자가 제공한 설계 주제를 분석하고, 프로젝트 코드베이스를 탐색하여 기존 구조를 파악한다.

`Glob`과 `Grep`으로 관련 코드, 설정 파일, 기존 문서를 탐색한다:
- 프로젝트의 디렉토리 구조와 주요 모듈
- 기존 아키텍처 패턴과 기술 스택
- 관련 도메인의 현재 구현 상태
- 기존 설계 문서나 ADR이 있는지 확인

#### 1b: 설계 유형 감지

`--type`이 지정되지 않은 경우, 설계 주제와 코드베이스 분석 결과를 기반으로 설계 유형을 자동 감지한다.

| 설계 유형 | 감지 키워드/패턴 | 설명 |
|-----------|----------------|------|
| `architecture` | 시스템, 서비스, 모듈, 마이크로서비스, 레이어, 인프라 | 시스템/서비스 수준의 구조 설계 |
| `api` | API, 엔드포인트, REST, GraphQL, gRPC, 라우트 | API 인터페이스 설계 |
| `database` | DB, 스키마, 테이블, ERD, 마이그레이션, 모델 | 데이터베이스/데이터 모델 설계 |
| `uiux` | UI, UX, 컴포넌트, 화면, 페이지, 대시보드, 폼 | UI/UX 및 프론트엔드 설계 |
| `system` | 연동, 통합, 파이프라인, 워크플로우, 배치 | 시스템 간 연동/통합 설계 |

**감지 결과를 사용자에게 표시:**

```markdown
## 요구사항 분석 결과

| 항목 | 내용 |
|------|------|
| 설계 주제 | <주제> |
| 감지된 설계 유형 | <유형> |
| 프로젝트 기술 스택 | <감지된 스택> |
| 관련 기존 코드 | <관련 파일/모듈 목록> |
| 기존 설계 문서 | <있으면 경로, 없으면 "없음"> |
```

`AskUserQuestion`으로 확인:
- "분석 결과가 맞습니다. 계속 진행" -- Step 2로 진행
- "설계 유형을 변경합니다: <유형>" -- 유형 변경 후 진행
- "추가 컨텍스트: <설명>" -- 추가 정보 반영 후 재분석
- "취소" -- 종료

### Step 2: 설계 초안 작성

해당 설계 유형에 맞는 구조화된 설계 초안을 작성한다. 코드베이스 분석 결과와 요구사항을 기반으로 구체적인 설계를 도출한다.

#### 설계 유형별 템플릿

설계 유형별 상세 템플릿은 각 참조 파일을 따른다:

| 설계 유형 | 참조 파일 |
|-----------|----------|
| `architecture` | `references/architecture.md` |
| `api` | `references/api.md` |
| `database` | `references/database.md` |
| `uiux` | `references/uiux.md` |
| `system` | `references/system.md` |

각 참조 파일의 "설계 초안 템플릿" 섹션에서 해당 유형의 구조화된 템플릿을 확인하고, 그 형식에 맞춰 설계 초안을 작성한다.

작성된 초안을 `docs/designs/draft_<주제(kebab-case)>.md`에 저장한 뒤 사용자에게 표시하고 `AskUserQuestion`으로 확인:
- "이대로 검토 진행" -- Step 3으로 진행
- "초안 수정: <수정 사항>" -- 수정 반영 후 다시 표시
- "취소" -- 종료

### Step 3: 전문가 패널 검토 (doc-review-panel 위임)

페르소나 추천·패널 구성·검토 실행·종합 리포트는 모두 `doc-review-panel` 스킬에 위임한다. doc-review-panel은 동일한 추천 알고리즘(`--recommend`), 프리셋 페르소나 세트, 순차/병렬 모드, 종합 리포트 형식을 보유하고 있어 design-workshop이 자체적으로 페르소나 로직을 중복 보관할 필요가 없다.

#### 3a: design-workshop 인수를 doc-review-panel 옵션으로 매핑

| design-workshop 인수 | doc-review-panel 옵션 |
|---|---|
| `--personas "A, B, C"` | `--personas "A, B, C"` |
| `--preset <이름>` | `--preset <이름>` |
| (둘 다 없음) | `--recommend` (자동 추천) |
| `--parallel` | `--parallel` |
| `--focus "..."` | `--focus "..."` |

`--focus`가 비어 있으면 "## 설계 유형별 검토 관점 가이드" 섹션의 해당 유형 키워드를 자동 주입한다. 예: API 설계 → `--focus "API 설계 검토: 일관성, 사용성, 보안, 진화 가능성"`.

#### 3b: doc-review-panel 호출

Step 2에서 저장한 `docs/designs/draft_<주제>.md`를 대상 문서로 doc-review-panel을 실행한다:

```
/doc-review-panel docs/designs/draft_<주제>.md [매핑된 옵션들]
```

doc-review-panel이 반환하는 "설계 검토 종합 리포트"(페르소나별 점수, 공통 강점, 핵심 개선 사항, 상충 의견, 핵심 질문)를 받아 Step 4에서 활용한다.

`AskUserQuestion`으로 확인:
- "검토 결과를 반영하여 설계 확정" -- Step 4로 진행
- "특정 이슈에 대해 추가 논의" -- 해당 이슈를 심층 분석
- "설계 초안을 대폭 수정 후 재검토" -- Step 2로 돌아가서 재작성
- "취소" -- 종료

### Step 4: 설계 확정 및 문서 생성

#### 4a: 최종 설계 확정

검토 결과에서 도출된 개선 사항을 반영하여 설계 초안을 최종 확정한다. 확정된 설계를 전체 표시하고 `AskUserQuestion`으로 최종 승인을 받는다:
- "승인. 문서를 생성합니다" -- 4b로 진행
- "추가 수정: <사항>" -- 수정 반영 후 다시 확인
- "취소" -- 종료

#### 4b: 설계 문서 생성

확정된 설계를 문서 파일로 생성한다.

**저장 경로:** `--output`으로 지정된 경로 또는 기본값 `docs/designs/`

**설계 문서 형식:** `docs/designs/<주제(kebab-case)>.md`

```markdown
# <설계 주제> - 설계 명세서

| 항목 | 내용 |
|------|------|
| 작성일 | <날짜> |
| 설계 유형 | <유형> |
| 상태 | 확정 |
| 검토 패널 | <페르소나 목록> |

## 1. 개요
[설계 배경, 목적, 범위]

## 2. 요구사항
[기능/비기능 요구사항 정리]

## 3. 설계 상세
[설계 유형별 상세 내용 - Step 2의 확정된 설계]

## 4. 검토 결과 요약
[Step 3의 종합 리포트 핵심 내용]

## 5. 결정 사항
[주요 설계 결정과 그 근거]

## 6. 향후 고려사항
[현재 범위 밖이지만 추후 검토 필요한 사항]
```

#### 4c: ADR 생성 (선택)

`--adr` 옵션이 있을 때만 실행한다.

기존 ADR 파일을 `Glob`으로 탐색하여 다음 번호를 결정한다.

**ADR 형식:** `docs/decisions/ADR-<번호>-<주제(kebab-case)>.md`

```markdown
# ADR-<번호>: <설계 결정 제목>

## 상태
승인됨

## 컨텍스트
[이 결정이 필요한 배경]

## 결정
[채택한 설계 방향]

## 대안
| 대안 | 장점 | 단점 | 탈락 사유 |
|------|------|------|-----------|

## 결과
[이 결정으로 인한 영향]
```

생성된 파일 경로를 표시한다.

### Step 5: 작업 지시서 생성 (선택)

`--with-plan` 옵션이 있거나, `AskUserQuestion`으로 사용자가 원할 때 실행한다.

#### 5a: feature-planner 존재 여부 확인

`Glob`으로 `**/feature-planner/SKILL.md` 파일을 탐색한다.

#### 5b-1: feature-planner 연계 (존재하는 경우)

feature-planner 스킬을 호출하여 확정된 설계를 기반으로 작업 계획을 자동 생성한다:
- 설계 문서 경로를 feature-planner에 전달
- Phase 분해, 품질 게이트, 롤백 전략 등을 포함한 계획 생성

#### 5b-2: 자체 작업 목록 생성 (존재하지 않는 경우)

feature-planner가 없으면 자체적으로 간단한 구현 단계 목록을 생성한다:

```markdown
## 구현 작업 목록: <주제>

### Phase 1: <단계명>
- [ ] <작업 1>
- [ ] <작업 2>
- [ ] <검증 항목>

### Phase 2: <단계명>
- [ ] <작업 1>
- [ ] <작업 2>
- [ ] <검증 항목>

...
```

결과를 화면에 표시하고 `AskUserQuestion`으로 확인:
- "파일로 저장" -- `docs/plans/PLAN_<주제>.md`로 저장
- "이대로 종료" -- 화면 출력만으로 종료

## 설계 유형별 검토 관점 가이드

각 설계 유형에서 페르소나가 중점적으로 검토해야 할 관점은 해당 유형의 참조 파일 "검토 관점 가이드" 섹션을 참조한다:

- `architecture`: `references/architecture.md` (모듈성, 확장성, 장애 격리, 운영성)
- `api`: `references/api.md` (일관성, 사용성, 보안, 진화 가능성)
- `database`: `references/database.md` (정규화, 쿼리 성능, 데이터 무결성, 마이그레이션)
- `uiux`: `references/uiux.md` (사용자 경험, 컴포넌트 재사용, 상태 관리, 접근성)
- `system`: `references/system.md` (통합 패턴, 데이터 흐름, 장애 전파, 보안 경계)

## 예외사항

### 설계 주제가 없는 경우
"설계 주제를 입력해 주세요. 예: `/design-workshop 사용자 인증 시스템 설계`"를 출력하고 종료한다.

### 설계 유형을 감지할 수 없는 경우
자동 감지 실패 시 설계 유형 목록을 표시하고 `AskUserQuestion`으로 사용자에게 선택을 요청한다.

### 병렬 모드에서 에이전트 팀 미활성화
에이전트 팀 기능이 비활성화되어 있으면 "에이전트 팀 기능(`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)이 비활성화되어 있습니다."를 안내하고 순차 모드로 폴백할지 `AskUserQuestion`으로 확인한다.

### 프로젝트 코드베이스가 없는 경우
코드베이스 탐색 결과가 없으면(빈 프로젝트 등) 요구사항 분석에서 코드베이스 분석을 건너뛰고, 사용자가 제공한 설계 주제만으로 진행한다.

### 병렬 모드에서 에이전트 팀 미활성화 (doc-review-panel 위임)
`--parallel` 옵션은 doc-review-panel로 전달되며, 거기서 에이전트 팀 활성화 여부를 확인하고 필요 시 순차 모드로 폴백한다. design-workshop은 직접 환경을 검사하지 않는다.

### feature-planner 스킬이 없는 경우 (Step 5)
feature-planner가 없으면 자체적으로 간단한 구현 단계 목록을 생성한다. 에러 없이 독립적으로 완료한다.

## Related Files

| File | Purpose |
|------|---------|
| `references/architecture.md` | 아키텍처 설계 초안 템플릿 및 검토 관점 가이드 |
| `references/api.md` | API 설계 초안 템플릿 및 검토 관점 가이드 |
| `references/database.md` | 데이터베이스 설계 초안 템플릿 및 검토 관점 가이드 |
| `references/uiux.md` | UI/UX 설계 초안 템플릿 및 검토 관점 가이드 |
| `references/system.md` | 시스템 연동 설계 초안 템플릿 |
| `custom/workflow/doc-review-panel/SKILL.md` | Step 3 페르소나 추천·검토·종합 리포트 위임 대상 |
| `custom/workflow/feature-planner/SKILL.md` | Step 5에서 연계하는 작업 지시서 생성 스킬 |
| `custom/workflow/feature-planner/plan-template.md` | feature-planner 연계 시 사용하는 계획 템플릿 |
| `settings.json` | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` 환경 변수 (병렬 모드) |
