---
name: smart-commit
description: 변경사항을 분석하여 논리적 커밋 단위로 분리하고, 민감정보/린트/테스트 검증 후 Conventional Commits 형식의 한국어 커밋 메시지를 생성하여 커밋합니다.
argument-hint: "[--push] [--amend] [선택: 파일 경로 또는 glob 패턴]"
---

# Smart Commit

## 목적

변경사항 분석 → 커밋 단위 분리 → 사전 검증 → 커밋 메시지 생성 → 커밋을 체계적으로 수행하는 통합 커밋 워크플로우.

- 논리적 커밋 단위 자동 분리
- 민감정보 검출 및 린트/테스트 사전 검증
- Conventional Commits 형식의 한국어 커밋 메시지 자동 생성
- 모노레포 scope 자동 감지

## 사용법

```
/smart-commit                          # 기본: 전체 변경사항 커밋
/smart-commit --push                   # 커밋 후 push
/smart-commit --amend                  # 직전 커밋 수정
/smart-commit --push --amend           # 직전 커밋 수정 후 push
/smart-commit src/                     # 특정 경로만 커밋
/smart-commit "*.ts"                   # glob 패턴으로 필터
```

### 옵션

| 옵션 | 설명 |
|------|------|
| `--push` | 커밋 완료 후 자동으로 `git push` 실행 |
| `--amend` | 직전 커밋을 수정 (새 변경사항 병합) |
| `[경로/패턴]` | 특정 파일이나 디렉토리만 대상으로 지정 |

## Workflow

### Step 1: 변경사항 분석

다음 명령을 실행하여 현재 저장소 상태를 파악한다:

```bash
git status
git diff --stat
git diff --cached --stat
```

결과를 아래 형식의 테이블로 정리한다:

```
| 상태 | 파일 | 변경 내용 |
|------|------|-----------|
| staged | src/app.ts | +12 -3 |
| unstaged | src/utils.ts | +5 -1 |
| untracked | src/new-file.ts | 신규 파일 |
```

**인수로 경로나 패턴이 주어진 경우**, 해당 경로에 매칭되는 파일만 대상으로 한다.

**변경 파일이 없으면** "커밋할 변경사항이 없습니다."를 출력하고 즉시 종료한다.

### Step 2: 커밋 단위 분리 제안

변경된 파일들을 분석하여 논리적 그룹으로 분리한다.

#### 커밋 단위 원칙

- **기능 단위**: 하나의 기능 완성 시 커밋
- **빌드 가능**: 각 커밋은 빌드 가능한 상태를 유지해야 한다
- **의미 있는 단위**: 너무 작거나 크지 않게 적절한 크기로 분리

#### 분리 기준

1. **같은 기능/목적**: 하나의 기능 구현이나 버그 수정에 관련된 파일들
2. **같은 디렉토리/모듈**: 동일 모듈 내의 관련 변경
3. **설정 vs 코드**: 설정 파일 변경과 소스 코드 변경 분리
4. **테스트 분리**: 테스트 코드는 관련 소스와 같은 그룹에 포함

#### 분리 로직

- **1개 그룹**이면 분리 없이 그대로 Step 3로 진행
- **2개 이상 그룹**이면 각 그룹의 파일 목록과 예상 커밋 type을 표시하고, `AskUserQuestion`으로 분리 여부를 확인:
  - "제안대로 분리하여 커밋" — 각 그룹별로 Step 3~5를 순차 실행
  - "하나로 합쳐서 커밋" — 전체를 하나의 커밋으로 진행
  - "직접 그룹 지정" — 사용자가 그룹핑을 재구성

#### 모노레포 감지

변경 파일이 여러 패키지에 걸쳐 있으면, 패키지 단위로 자동 그룹핑을 우선 제안한다. 모노레포 감지는 [모노레포 Scope 감지](#모노레포-scope-감지) 섹션 참조.

### Step 3: 사전 검증

#### 3a: 민감정보 검출

staged 대상 파일에서 다음 패턴을 검사한다:

**파일명 기반 검출:**
- `.env`, `.env.local`, `.env.production` 등 환경변수 파일
- `credentials.json`, `serviceAccountKey.json` 등 인증 파일
- `*.pem`, `*.key`, `*.p12` 등 인증서/키 파일

**내용 기반 검출 (Grep 도구 사용):**

다음 패턴을 staged 대상 파일에서 검색한다:

```
(password|secret|api_key|apikey|api_secret|access_token|auth_token|private_key)\s*[:=]\s*["'][^"']{8,}["']
```

추가 검출 대상:
- AWS 키 패턴: `AKIA[0-9A-Z]{16}`
- 일반 토큰 패턴: `(ghp_|gho_|github_pat_|sk-|pk_live_|pk_test_|sk_live_|sk_test_)[a-zA-Z0-9]+`

**`.gitignore` 위반 검출:**

staging 대상 파일이 `.gitignore` 패턴에 해당하는지 확인한다:

```bash
# .gitignore에 의해 무시되어야 하는 파일이 staging되었는지 확인
git ls-files --cached --ignored --exclude-standard
```

결과가 있으면 경고를 표시한다. 이는 `git add -f`로 강제 추가되었거나, `.gitignore`가 나중에 수정된 경우에 발생한다.

**대용량/바이너리 파일 검출:**
- 1MB 이상 파일 경고
- 바이너리 파일 (이미지, 압축파일 등) 경고

**검출 시 처리:**
- 발견된 항목을 경고 테이블로 표시
- `AskUserQuestion`으로 계속 진행 여부 확인:
  - "해당 파일 제외하고 계속"
  - "무시하고 계속 진행"
  - "커밋 중단"

#### 3b: 린트/테스트 실행

프로젝트의 린트/테스트 도구를 자동 감지하여 실행한다.

**감지 우선순위:**

1. `package.json` — `scripts.typecheck`, `scripts.lint`, `scripts.build`, `scripts.test` 필드 확인
   ```bash
   # typecheck가 있으면 (type-check도 확인)
   npm run typecheck
   # lint가 있으면
   npm run lint
   # build가 있으면
   npm run build
   # test가 있으면
   npm run test
   ```

2. `Makefile` — `lint`, `test` 타겟 존재 확인
   ```bash
   make lint
   make test
   ```

3. `pyproject.toml` — `[tool.ruff]`, `[tool.pytest]` 등 확인
   ```bash
   ruff check .
   pytest
   ```

4. `Cargo.toml` — Rust 프로젝트
   ```bash
   cargo clippy
   cargo test
   ```

5. `go.mod` — Go 프로젝트
   ```bash
   golangci-lint run
   go test ./...
   ```

**감지된 도구가 없으면** 이 단계를 건너뛴다.

**실행 결과 처리:**
- **성공**: 다음 단계로 진행
- **실패**: 실패 내용을 표시하고 `AskUserQuestion`으로 확인:
  - "무시하고 커밋 진행"
  - "커밋 중단 (수정 후 재시도)"

### Step 4: 커밋 메시지 생성

`git diff --cached` (staged인 경우) 또는 대상 파일의 diff를 분석하여 커밋 메시지를 생성한다.

#### 메시지 생성 규칙

**제목 (첫 줄):**
```
<type>(<scope>): <한국어 설명>
```
- 50자 이내
- type은 영어 소문자
- 설명은 한국어, 명사형 종결 (예: "로그인 기능 추가", "버튼 스타일 수정")

**본문 (선택):**
- 빈 줄로 제목과 구분
- 한국어로 작성
- 72자 줄바꿈
- 주요 변경사항을 불릿 포인트로 나열:
  ```
  - 사용자 인증 미들웨어 추가
  - JWT 토큰 검증 로직 구현
  - 인증 실패 시 401 응답 처리
  ```

**푸터:**
- `Co-Authored-By: Claude <noreply@anthropic.com>` (필수)
- Breaking change가 있으면: `BREAKING CHANGE: <설명>`
- 관련 이슈가 있으면: `Closes #이슈번호`

### Step 5: 사용자 확인 및 커밋

생성된 커밋 메시지를 코드 블록으로 표시한 후, `AskUserQuestion`으로 확인한다:

- "이대로 커밋" — 아래 커밋 실행
- "메시지 수정" — 사용자가 수정한 메시지로 커밋
- "취소" — 커밋 중단

**커밋 실행:**

```bash
# 대상 파일 staging
git add <파일 목록>

# 커밋 (HEREDOC으로 메시지 전달)
git commit -m "$(cat <<'EOF'
<커밋 메시지>
EOF
)"
```

**커밋 완료 후 확인:**

```bash
git log --oneline -3
```

커밋이 정상적으로 생성되었는지 최근 로그를 출력하여 확인한다.

**여러 그룹으로 분리된 경우**, 각 그룹별로 Step 4 → Step 5를 순차 반복한다.

### Step 6: (선택) Push

`--push` 플래그가 있을 때만 실행한다.

```bash
# upstream 확인
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null

# upstream이 있으면
git push

# upstream이 없으면
git push -u origin $(git branch --show-current)
```

push 전에 `AskUserQuestion`으로 최종 확인:
- "Push 실행"
- "Push 건너뛰기"

## 커밋 메시지 규칙

### Type 목록

| Type | 사용 시점 |
|------|-----------|
| `feat` | 새로운 기능 추가 |
| `fix` | 버그 수정 |
| `refactor` | 기능 변경 없는 코드 개선 |
| `docs` | 문서 변경 |
| `test` | 테스트 추가/수정 |
| `chore` | 빌드, 패키지 매니저 등 기타 |
| `style` | 코드 포맷팅 |
| `perf` | 성능 개선 |
| `ci` | CI/CD 설정 변경 |

### Scope 규칙

- 변경된 주요 디렉토리/모듈명, 모노레포에서는 패키지명 사용
- 여러 모듈에 걸친 변경이면 scope 생략 가능
- scope는 소문자, 하이픈 구분 (예: `user-auth`)

### 제목 작성 가이드

- **좋은 예:** `feat(auth): 소셜 로그인 기능 추가`, `fix(cart): 수량 0 입력 시 에러 수정`
- **나쁜 예 (금지):** `update code`, `fixed bug`, `WIP`, `minor changes`, `temp`

## Amend 모드

`--amend` 플래그 사용 시:

1. 직전 커밋 정보 표시: `git log -1 --format="%H%n%s%n%b" HEAD` + `git diff HEAD~1 --stat`
2. 현재 변경사항(staged + unstaged)도 함께 표시
3. 병합된 전체 변경사항을 기반으로 커밋 메시지를 재생성
4. `AskUserQuestion`으로 확인: "새 메시지로 amend" / "기존 메시지 유지 (--no-edit)" / "메시지 직접 수정" / "취소"
5. `git add <파일 목록>` → `git commit --amend -m "$(cat <<'EOF'...EOF)"` 실행

**주의:** `git log @{u}..HEAD --oneline 2>/dev/null`로 push 여부를 확인하고, 이미 push된 커밋이면 force push 경고를 표시한다.

## 모노레포 Scope 감지

**감지 파일:** `pnpm-workspace.yaml`, `lerna.json`, `package.json`(workspaces), 또는 `packages/*/`·`apps/*/` 디렉토리 구조

**Scope 추출:** 변경 파일 경로에서 패키지 디렉토리를 추출 (예: `packages/web/src/app.ts` → scope `web`). 여러 패키지에 걸치면 scope 생략 또는 커밋 단위 분리. 루트 설정 파일은 scope 없이 커밋.

## 예외사항

### 빈 커밋
변경사항이 없으면 커밋을 생성하지 않는다. `--allow-empty`는 지원하지 않는다.

### Merge 충돌 상태
`git status`에서 merge 충돌(Unmerged paths)이 감지되면:
- "Merge 충돌이 해결되지 않았습니다. 충돌을 먼저 해결해주세요."를 출력하고 종료

### Detached HEAD
`git symbolic-ref HEAD` 실패 시:
- "Detached HEAD 상태입니다. 브랜치를 checkout한 후 다시 시도해주세요."를 출력하고 종료

### Git 저장소가 아닌 경우
`git rev-parse --git-dir` 실패 시:
- "Git 저장소가 아닙니다."를 출력하고 종료

## Related Files

이 스킬은 단일 파일(`SKILL.md`)로 구성되며, 외부 의존성이 없습니다.
프로젝트의 기존 Git 설정(`.gitignore`, `.gitattributes` 등)을 존중합니다.
