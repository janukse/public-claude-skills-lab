---
name: code-convention-quality
description: 코드 품질 컨벤션 가이드 및 검증. Core(code-convention) 스킬을 확장하여 주석/문서화, 테스트, Git/협업 규칙을 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# 코드 품질 컨벤션

## 기반 스킬

이 스킬은 **Core 코드 컨벤션**(`code-convention/SKILL.md`)의 확장입니다.

**적용 우선순위:**
1. 이 스킬(코드 품질 확장)의 규칙을 우선 적용
2. Core 스킬의 규칙을 병행 적용
3. 충돌 시 이 스킬의 규칙이 우선

> **Claude에게:** Guide 모드 실행 시, 먼저 `code-convention/SKILL.md`를 읽고 Core 규칙을 숙지한 후 이 스킬의 규칙을 추가 적용하세요. Verify 모드에서는 Core 검증과 코드 품질 검증을 모두 수행합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-quality guide` | 코드 품질 규칙을 참조하여 적용 |
| Verify | `/code-convention-quality verify src/` | 코드 품질 검증 + Core 검증 병행 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 버그, 보안 취약점, 유지보수 심각 저해 |
| `[Warning]` | 권장 | 가독성, 일관성, 팀 협업에 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

---

## [Guide 모드] 코드 품질 규칙

### G6. 주석/문서화

#### G6.1 공개 API에 JSDoc [Warning]

**규칙:** 라이브러리/패키지의 공개 API와 복잡한 함수에는 JSDoc 주석을 작성합니다.

**이유:** JSDoc은 IDE 자동완성과 문서 생성에 활용됩니다.

**Good:**
```typescript
/**
 * 사용자 목록을 페이지네이션하여 조회합니다.
 *
 * @param options - 조회 옵션
 * @returns 사용자 목록과 페이지 정보
 * @throws {ValidationError} page가 0 이하인 경우
 *
 * @example
 * const result = await getUsers({ page: 1, limit: 20 });
 */
async function getUsers(options: GetUsersOptions): Promise<PaginatedResult<User>> {
  // ...
}
```

**Bad:**
```typescript
// 사용자 목록 조회
async function getUsers(options: GetUsersOptions): Promise<PaginatedResult<User>> {
  // ...
}
```

#### G6.2 TODO/FIXME 형식 [Info]

**규칙:** TODO/FIXME 주석은 담당자와 이유를 함께 기록합니다. 이슈 번호를 연결하면 더 좋습니다.

**이유:** 담당자 없는 TODO는 방치되기 쉽습니다.

**Good:**
```typescript
// TODO(@username): 캐싱 레이어 추가 (#123)
// FIXME(@username): 동시성 이슈로 race condition 발생 가능 (#456)
```

**Bad:**
```typescript
// TODO: fix this
// FIXME: doesn't work sometimes
// HACK: temporary workaround
```

#### G6.3 매직 넘버 금지 [Warning]

**규칙:** 의미를 알 수 없는 숫자 리터럴은 명명된 상수로 추출합니다.

**이유:** 매직 넘버는 코드의 의도를 숨기고 유지보수를 어렵게 합니다.

**Good:**
```typescript
const MAX_LOGIN_ATTEMPTS = 5;
const SESSION_TIMEOUT_MS = 30 * 60 * 1000; // 30분
const PAGINATION_DEFAULT_LIMIT = 20;

if (loginAttempts >= MAX_LOGIN_ATTEMPTS) {
  lockAccount(userId);
}
```

**Bad:**
```typescript
if (loginAttempts >= 5) {
  lockAccount(userId);
}

setTimeout(callback, 1800000);
```

#### G6.4 자기 문서화 코드 [Info]

**규칙:** "무엇"을 하는지는 코드로, "왜" 하는지는 주석으로 설명합니다. 코드가 자명한 경우 주석을 생략합니다.

**이유:** 불필요한 주석은 코드와 동기화되지 않아 오히려 혼란을 줍니다.

**Good:**
```typescript
// 비즈니스 요구사항: 30일 이상 비활성 사용자는 자동 비활성화
const INACTIVE_THRESHOLD_DAYS = 30;

const inactiveUsers = users.filter(
  (user) => daysSinceLastLogin(user) > INACTIVE_THRESHOLD_DAYS,
);
```

**Bad:**
```typescript
// 사용자를 필터링한다 (코드가 이미 말하고 있음)
const filteredUsers = users.filter((user) => user.isActive);

// i를 1 증가시킨다 (자명한 주석)
i++;
```

---

### G7. 테스트

#### G7.1 테스트 파일 위치 [Info]

**규칙:** 테스트 파일은 소스 파일과 같은 디렉토리에 위치하거나, 프로젝트 루트의 `tests/` 디렉토리에 동일 구조로 배치합니다. 프로젝트의 기존 패턴을 따릅니다.

**이유:** 테스트와 소스의 근접성은 유지보수 편의성을 높입니다.

**Good:**
```
# 패턴 1: 소스 옆 배치
src/services/user-service.ts
src/services/user-service.test.ts

# 패턴 2: tests 디렉토리 미러
src/services/user-service.ts
tests/services/user-service.test.ts
```

#### G7.2 테스트 네이밍 (describe/it) [Warning]

**규칙:** `describe`에는 테스트 대상을, `it`에는 기대 동작을 명사구 또는 문장으로 작성합니다.

**이유:** 테스트 실패 시 어떤 동작이 깨졌는지 바로 알 수 있습니다.

**Good:**
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid input', () => { /* ... */ });
    it('should throw ValidationError when email is invalid', () => { /* ... */ });
    it('should hash password before saving', () => { /* ... */ });
  });
});
```

**Bad:**
```typescript
describe('test', () => {
  it('works', () => { /* ... */ });
  it('test 2', () => { /* ... */ });
  it('error case', () => { /* ... */ });
});
```

#### G7.3 AAA 패턴 (Arrange-Act-Assert) [Warning]

**규칙:** 테스트는 Arrange(준비) → Act(실행) → Assert(검증) 패턴으로 구조화합니다.

**이유:** 일관된 구조는 테스트의 의도와 흐름을 명확하게 합니다.

**Good:**
```typescript
it('should calculate total with discount', () => {
  // Arrange
  const items: CartItem[] = [
    { id: '1', name: 'Book', price: 20, quantity: 2 },
    { id: '2', name: 'Pen', price: 5, quantity: 3 },
  ];
  const discount = 0.1;

  // Act
  const total = calculateTotal(items, discount);

  // Assert
  expect(total).toBe(49.5); // (20*2 + 5*3) * 0.9
});
```

**Bad:**
```typescript
it('should calculate total with discount', () => {
  expect(calculateTotal([{ id: '1', name: 'Book', price: 20, quantity: 2 }], 0.1)).toBe(36);
  expect(calculateTotal([], 0)).toBe(0);
  expect(calculateTotal([{ id: '1', name: 'Pen', price: 5, quantity: 1 }], 0.5)).toBe(2.5);
});
```

#### G7.4 모킹 최소화 [Warning]

**규칙:** 외부 의존성(API, DB, 파일 시스템)만 모킹합니다. 내부 함수는 가능한 실제 구현을 사용합니다.

**이유:** 과도한 모킹은 테스트가 구현에 결합되어 리팩토링을 방해합니다.

**Good:**
```typescript
// 외부 API만 모킹
const mockFetch = vi.spyOn(global, 'fetch').mockResolvedValue(
  new Response(JSON.stringify({ id: '1', name: 'Alice' })),
);

// 내부 로직은 실제 실행
const result = await userService.getUser('1');
expect(result.name).toBe('Alice');
```

**Bad:**
```typescript
// 내부 함수까지 모킹 (구현에 결합)
vi.mock('./validators', () => ({
  validateEmail: vi.fn().mockReturnValue(true),
}));
vi.mock('./transformers', () => ({
  transformUser: vi.fn().mockReturnValue({ id: '1' }),
}));
```

#### G7.5 커버리지 기준 [Info]

**규칙:** 새 코드의 테스트 커버리지는 80% 이상을 목표로 합니다. 핵심 비즈니스 로직은 90% 이상을 권장합니다.

**이유:** 커버리지는 테스트 누락을 발견하는 도구이며, 100%를 강제하지는 않습니다.

**Good:**
```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      thresholds: {
        lines: 80,
        branches: 80,
        functions: 80,
      },
    },
  },
});
```

---

### G8. Git/협업

#### G8.1 Conventional Commits [Warning]

**규칙:** 커밋 메시지는 Conventional Commits 형식을 따릅니다: `<type>(<scope>): <description>`.

**이유:** 일관된 커밋 메시지는 자동 변경 로그 생성과 시맨틱 버저닝에 활용됩니다.

**Good:**
```
feat(auth): add OAuth2 login support
fix(api): handle null response from payment gateway
refactor(user): extract validation logic to separate module
docs(readme): update installation instructions
test(cart): add edge case tests for discount calculation
chore(deps): bump vitest to v2.1.0
```

**Bad:**
```
fixed stuff
update
WIP
asdf
modify user.ts
```

#### G8.2 브랜치 네이밍 [Info]

**규칙:** 브랜치명은 `<type>/<description>` 형식을 사용합니다.

**이유:** 브랜치 목적을 빠르게 파악하고, CI/CD 자동화에 활용할 수 있습니다.

**Good:**
```
feat/oauth-login
fix/payment-null-response
refactor/user-validation
chore/update-dependencies
```

**Bad:**
```
my-branch
temp
fix
update-stuff
```

#### G8.3 PR 크기 제한 [Warning]

**규칙:** PR은 변경 파일 10개 또는 변경 줄 수 400줄 이하로 유지합니다.

**이유:** 작은 PR은 리뷰 품질을 높이고, 피드백 루프를 단축합니다.

#### G8.4 코드 리뷰 체크리스트 [Info]

**규칙:** 코드 리뷰 시 다음을 확인합니다:
- 네이밍이 의도를 표현하는가
- 에러 처리가 적절한가
- 테스트가 핵심 경로를 커버하는가
- 보안 취약점이 없는가
- 불필요한 복잡성이 없는가

---

## [Verify 모드] 코드 품질 검증 워크플로우

### Step 1: 검증 대상 수집

인수로 전달된 파일 경로 또는 glob 패턴을 사용하여 검증 대상 파일을 수집합니다. 인수가 없으면 프로젝트의 소스 디렉토리 전체를 대상으로 합니다.

Glob 도구를 사용하여 대상 파일을 수집합니다:
- 패턴: `**/*.{ts,tsx,js,jsx}`
- `node_modules/`, `dist/`, `.next/` 디렉토리는 제외

### Step 2: Core 검증 병행

Core 스킬(`code-convention/SKILL.md`)의 Verify 워크플로우를 먼저 실행하여 기본 규칙 검증을 수행합니다.

### Step 3: G6 주석/문서화 검사

Grep 도구를 사용하여 탐지합니다:

담당자 없는 TODO/FIXME:
- 패턴: `TODO|FIXME`
- Glob 필터: `*.{ts,tsx}`
- 결과에서 `@` 포함 행은 면제 처리

매직 넘버 탐지:
- 패턴: `=== [0-9]{2,}|> [0-9]{2,}|< [0-9]{2,}`
- Glob 필터: `*.{ts,tsx}`
- **면제:** test/spec 파일의 기대값 숫자 리터럴
- **면제:** HTTP 상태 코드 (200, 201, 204, 301, 302, 400, 401, 403, 404, 409, 422, 500, 502, 503)
- **면제:** 일반적 상수 할당 (`const MAX_* =`, `const *_SIZE =` 등 명명된 상수에 할당된 값)
- **면제:** 배열 인덱스 접근 (`[0]`, `[1]`)

### Step 4: G7 테스트 검사

Glob 도구를 사용하여 테스트 파일 존재를 확인합니다:
- 패턴: `**/*.{test,spec}.{ts,tsx}`

Grep 도구를 사용하여 describe/it 네이밍을 확인합니다:
- 패턴: `it\(['"]`
- Glob 필터: `*.{test,spec}.{ts,tsx}`

### Step 5: G8 Git 검사

```bash
# 최근 커밋 메시지 형식 확인
git log --oneline -20

# 현재 브랜치명 확인
git branch --show-current
```

### Step 6: 보고서 생성

Core 검증 결과와 코드 품질 검증 결과를 통합하여 보고서를 출력합니다.

```markdown
## 코드 품질 컨벤션 검증 보고서

**검증 대상:** <경로>
**검증 일시:** <날짜>
**적용 규칙:** Core + 코드 품질 확장

### 요약

| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| Core: G1-G5 | ... | ... | ... | ... |
| Quality: G6. 주석/문서화 | 0 | 1 | 0 | ⚠️ |
| Quality: G7. 테스트 | 0 | 0 | 1 | ✅ |
| Quality: G8. Git/협업 | 0 | 0 | 0 | ✅ |

### 상세 위반 목록

| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
| 1 | Warning | G6.3 | src/utils.ts | 15 | 매직 넘버 사용 | 명명된 상수로 추출 |
| ... | | | | | | |

### 상태 기준
- ✅ Error 0개 & Warning 0개
- ⚠️ Error 0개 & Warning 1개 이상
- ❌ Error 1개 이상
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **서드파티 타입 호환** — 외부 라이브러리의 문서화 컨벤션이 다른 경우 (예: `@types/*` 패키지의 JSDoc 스타일)
2. **테스트 코드의 매직 넘버** — 테스트의 기대값으로 사용되는 숫자 리터럴
3. **프레임워크 컨벤션** — React의 `useState`, Vue의 `ref()` 등 프레임워크가 정한 패턴
4. **코드 생성기 출력** — Prisma, GraphQL Codegen 등 자동 생성된 코드
5. **레거시 코드 수정** — 기존 코드의 스타일을 유지하면서 최소한의 수정만 하는 경우 (새 코드에는 규칙 적용)
6. **설정 파일** — `*.config.ts`, `*.config.js` 등 도구 설정 파일의 특수 구조

## Related Files

| File | Purpose |
|------|---------|
| `code-convention/SKILL.md` | Core 코드 컨벤션 (G1-G5, G9 규칙) |
| `vitest.config.*` / `jest.config.*` | 테스트 설정 (커버리지 기준 확인) |
| `.eslintrc.*` / `eslint.config.*` | ESLint 설정 (포매팅 규칙 위임) |
