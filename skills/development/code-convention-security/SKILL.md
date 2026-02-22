---
name: code-convention-security
description: TS/JS 보안 컨벤션 가이드 및 검증. Core(code-convention) 스킬을 확장하여 XSS 방지, 입력 검증, 환경 변수, 민감 정보 보호, 암호학적 난수 생성 규칙을 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# TS/JS 보안 컨벤션

## 기반 스킬

이 스킬은 **Core 코드 컨벤션**(`code-convention/SKILL.md`)의 확장입니다.

**적용 우선순위:**
1. 이 스킬(Security 확장)의 규칙을 우선 적용
2. Core 스킬의 규칙을 병행 적용
3. 충돌 시 이 스킬의 규칙이 우선

> **Claude에게:** Guide 모드 실행 시, 먼저 `code-convention/SKILL.md`를 읽고 Core 규칙을 숙지한 후 이 스킬의 규칙을 추가 적용하세요. Verify 모드에서는 Core 검증과 Security 검증을 모두 수행합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-security guide` | 보안 규칙을 적용하여 코드 작성 |
| Verify | `/code-convention-security verify src/` | 보안 코드 검증 + Core 검증 병행 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 보안 취약점, 데이터 유출 |
| `[Warning]` | 권장 | 보안 모범 사례 |
| `[Info]` | 참고 | 개선 제안 |

---

## [Guide 모드] 보안 코드 작성 규칙

### G9. 보안

#### G9.1 XSS 방지 [Error]

**규칙:** 사용자 입력을 DOM에 삽입할 때 반드시 이스케이프하거나 안전한 API를 사용합니다.

**이유:** XSS 공격은 세션 탈취, 데이터 유출 등 심각한 보안 위협입니다.

**Good:**
```typescript
// React: 기본적으로 이스케이프 처리
return <div>{userInput}</div>;

// DOM API: textContent 사용
element.textContent = userInput;

// 필요 시 DOMPurify 사용
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(htmlContent);
```

**Bad:**
```typescript
// dangerouslySetInnerHTML 무검증 사용
return <div dangerouslySetInnerHTML={{ __html: userInput }} />;

// innerHTML 직접 설정
element.innerHTML = userInput;

// eval 사용
eval(userInput);
```

#### G9.2 입력 검증 [Error]

**규칙:** 외부 입력(API 요청, URL 파라미터, 폼 데이터)은 반드시 검증 후 사용합니다. Zod, Yup 등 스키마 검증 라이브러리를 권장합니다.

**이유:** 검증되지 않은 입력은 인젝션 공격과 예상치 못한 동작을 유발합니다.

**Good:**
```typescript
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
});

function createUser(input: unknown) {
  const validated = CreateUserSchema.parse(input);
  // validated는 안전한 타입
  return userRepository.create(validated);
}
```

**Bad:**
```typescript
function createUser(input: any) {
  // 검증 없이 직접 사용
  return userRepository.create({
    name: input.name,
    email: input.email,
    age: input.age,
  });
}
```

#### G9.3 환경 변수 관리 [Error]

**규칙:** 환경 변수는 시작 시점에 검증하고, 타입 안전한 설정 객체로 변환합니다. `.env` 파일은 `.gitignore`에 추가합니다.

**이유:** 런타임에 환경 변수 누락을 발견하면 장애로 이어집니다.

**Good:**
```typescript
const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']),
});

export const env = envSchema.parse(process.env);
```

**Bad:**
```typescript
// 검증 없이 직접 사용
const dbUrl = process.env.DATABASE_URL; // undefined일 수 있음
const port = Number(process.env.PORT); // NaN일 수 있음
```

#### G9.4 민감 정보 보호 [Error]

**규칙:** API 키, 비밀번호, 토큰 등 민감 정보는 코드에 하드코딩하지 않습니다.

**이유:** 코드에 포함된 민감 정보는 버전 관리 시스템을 통해 유출됩니다.

**Good:**
```typescript
// 환경 변수에서 로드
const apiKey = env.STRIPE_API_KEY;

// .gitignore에 등록
// .env
// .env.local
// .env.*.local
```

**Bad:**
```typescript
const API_KEY = 'sk_live_1234567890abcdef';
const DB_PASSWORD = 'super_secret_password';
```

#### G9.5 의존성 보안 [Warning]

**규칙:** 정기적으로 의존성 보안 취약점을 점검하고, 알려진 취약점이 있는 패키지를 업데이트합니다.

**이유:** 서드파티 패키지의 취약점은 공급망 공격의 진입점이 됩니다.

**Good:**
```bash
# 정기적으로 실행
npm audit
npx npm-check-updates --doctor

# CI에서 자동 점검
# .github/workflows/security.yml
# - run: npm audit --audit-level=high
```

#### G9.6 민감 데이터 메모리 제로화 [Warning]

**규칙:** 비밀번호, 토큰, 암호화 키 등 민감한 데이터를 담은 버퍼나 배열은 사용 후 즉시 제로화합니다.

**이유:** 메모리에 남아 있는 민감 데이터는 메모리 덤프, 코어 덤프, 스왑 파일을 통해 유출될 수 있습니다. JavaScript 문자열은 불변(immutable)이므로, 민감 데이터는 가능한 한 `Uint8Array`나 `Buffer`로 다루고 사용 후 즉시 덮어씁니다.

**Good:**
```typescript
function verifyPassword(input: string, storedHash: Buffer): boolean {
  const inputBuffer = Buffer.from(input, 'utf-8');
  try {
    return timingSafeEqual(inputBuffer, storedHash);
  } finally {
    inputBuffer.fill(0); // 사용 후 즉시 제로화
  }
}

// 암호화 키 사용 후 제로화
function encryptData(data: Buffer, key: Uint8Array): Buffer {
  try {
    return performEncryption(data, key);
  } finally {
    key.fill(0);
  }
}
```

**Bad:**
```typescript
// 문자열 비교 (타이밍 공격 취약 + 메모리 잔류)
function verifyPassword(input: string, stored: string): boolean {
  return input === stored;
}

// 키가 GC될 때까지 메모리에 평문으로 존재
const encryptionKey = getKeyFromVault();
const encrypted = encrypt(data, encryptionKey);
// encryptionKey가 제로화되지 않고 메모리에 잔류
```

#### G9.7 프론트엔드 비밀키 노출 금지 [Error]

**규칙:** 서버 측 비밀키(API 시크릿, DB 자격증명, 서명 키 등)는 절대 프론트엔드/클라이언트로 전송하지 않습니다. 클라이언트에 노출되는 환경 변수와 서버 전용 환경 변수를 명확히 구분합니다.

**이유:** 프론트엔드 코드는 브라우저 개발자 도구로 누구나 열람할 수 있습니다. API 응답이나 번들에 포함된 비밀키는 곧바로 공격자에게 노출됩니다.

**Good:**
```typescript
// 서버 전용 환경 변수 — 절대 클라이언트로 보내지 않음
const SERVER_ONLY = {
  DB_PASSWORD: env.DB_PASSWORD,
  JWT_SECRET: env.JWT_SECRET,
  STRIPE_SECRET_KEY: env.STRIPE_SECRET_KEY,
};

// 클라이언트 노출 가능 환경 변수 — 공개 키만 포함
const CLIENT_SAFE = {
  STRIPE_PUBLIC_KEY: env.STRIPE_PUBLIC_KEY,
  API_BASE_URL: env.API_BASE_URL,
};

// API 응답에서 민감 정보 제외
function getUserProfile(user: User) {
  const { passwordHash, apiToken, ...safeProfile } = user;
  return safeProfile;
}
```

**Bad:**
```typescript
// API 응답에 비밀키 포함
app.get('/config', (req, res) => {
  res.json({
    apiKey: env.STRIPE_SECRET_KEY,    // 비밀키 노출!
    dbUrl: env.DATABASE_URL,           // DB 자격증명 노출!
  });
});

// 사용자 객체를 필터링 없이 그대로 반환
app.get('/users/:id', async (req, res) => {
  const user = await db.users.findById(req.params.id);
  res.json(user); // passwordHash, 내부 토큰 등 모두 노출
});
```

#### G9.8 암호학적 안전한 난수 생성 [Error]

**규칙:** 토큰, 세션 ID, nonce, 비밀번호 솔트 등 보안 관련 난수는 반드시 암호학적으로 안전한 난수 생성기(CSPRNG)를 사용합니다. `Math.random()`은 보안 목적에 사용하지 않습니다.

**이유:** `Math.random()`은 예측 가능한 의사 난수 생성기(PRNG)로, 공격자가 출력을 예측하여 토큰 위조, 세션 하이재킹 등에 악용할 수 있습니다.

**Good:**
```typescript
// Node.js — crypto 모듈 사용
import { randomBytes, randomUUID } from 'node:crypto';

const sessionToken = randomBytes(32).toString('hex');
const requestId = randomUUID();

// 브라우저 — Web Crypto API 사용
const buffer = new Uint8Array(32);
crypto.getRandomValues(buffer);
const token = Array.from(buffer, (b) => b.toString(16).padStart(2, '0')).join('');

// 범용 (Node.js + 브라우저)
const id = crypto.randomUUID();
```

**Bad:**
```typescript
// Math.random()으로 토큰 생성 — 예측 가능!
const token = Math.random().toString(36).substring(2);
const sessionId = `sess_${Math.random().toString(36)}`;

// Date 기반 ID — 충돌 및 예측 가능
const uniqueId = `id_${Date.now()}`;
```

---

## [Verify 모드] 보안 코드 검증 워크플로우

### Step 1: 검증 대상 수집

인수로 전달된 파일 경로 또는 glob 패턴을 사용하여 검증 대상 파일을 수집합니다. 인수가 없으면 프로젝트의 소스 디렉토리 전체를 대상으로 합니다.

Glob 도구를 사용하여 대상 파일을 수집합니다:
- 패턴: `**/*.{ts,tsx,js,jsx}`
- `node_modules/`, `dist/`, `.next/` 디렉토리는 제외

### Step 2: Core 검증 병행

Core 스킬(`code-convention/SKILL.md`)의 Verify 워크플로우를 먼저 실행하여 기본 규칙 검증을 수행합니다.

### Step 3: G9 보안 검사

Grep 도구를 사용하여 보안 취약점을 탐지합니다:

하드코딩된 시크릿:
- 패턴: `(api_key|apiKey|secret|password|token)\s*[:=]\s*['"]`
- Glob 필터: `*.{ts,tsx}`
- 경로: `<target-path>`
- **면제:** test/spec/mock/fixture 파일의 더미 값
- **면제:** `.example`, `.template` 확장자 파일
- **면제:** 타입/인터페이스 정의 행 (`interface`, `type`, `: string`)

.env 파일 gitignore 확인:
- 패턴: `\.env`
- 경로: `.gitignore`

innerHTML/dangerouslySetInnerHTML 사용:
- 패턴: `innerHTML|dangerouslySetInnerHTML`
- Glob 필터: `*.{ts,tsx}`

프론트엔드 환경 변수에 비밀키 포함 여부:
- 패턴: `(REACT_APP_|NEXT_PUBLIC_|VITE_).*(SECRET|PASSWORD)`
- Glob 필터: `*.{env*,ts,tsx}`

API 응답에서 민감 필드 직접 반환:
- 패턴: `res\.(json|send).*\b(password|secret|token|apiKey)\b`
- Glob 필터: `*.ts`
- 대소문자 무시 옵션 사용

Math.random()을 보안 목적에 사용하는 패턴:
- 패턴: `Math\.random\(\)`
- Glob 필터: `*.{ts,tsx}`
- 결과에서 test/spec/mock 파일은 면제 처리

### Step 4: 보고서 생성

Core 검증 결과와 Security 검증 결과를 통합하여 보고서를 출력합니다.

```markdown
## 보안 코드 컨벤션 검증 보고서

**검증 대상:** <경로>
**검증 일시:** <날짜>
**적용 규칙:** Core + Security 확장

### 요약

| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| Core: G1-G5 | ... | ... | ... | ... |
| Security: G9. 보안 | 1 | 0 | 0 | ❌ |
| **합계** | **...** | **...** | **...** | — |

### 상세 위반 목록

| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
| 1 | Error | G9.4 | src/config.ts | 12 | API 키 하드코딩 | 환경 변수로 이동 |
| ... | | | | | | |

### 상태 기준
- ✅ Error 0개 & Warning 0개
- ⚠️ Error 0개 & Warning 1개 이상
- ❌ Error 1개 이상
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **서드파티 타입 호환** — 외부 라이브러리가 요구하는 타입/패턴과의 호환을 위한 코드
2. **테스트 코드의 더미 시크릿/토큰** — test/spec/mock/fixture 파일에서 사용하는 더미 비밀번호, 토큰, API 키
3. **프레임워크 컨벤션** — Next.js, Remix 등 메타 프레임워크가 정한 환경 변수 접두사 규칙 및 파일 구조
4. **코드 생성기 출력** — ORM, GraphQL codegen 등 자동 생성된 코드
5. **설정 파일의 예시 값** — `.example`, `.template` 확장자 파일에 포함된 플레이스홀더 시크릿
6. **마이그레이션 중인 코드** — 점진적으로 보안 규칙을 적용 중인 레거시 코드 (단, 보고서에 [Info]로 기록)

## Related Files

| File | Purpose |
|------|---------|
| `code-convention/SKILL.md` | Core 규칙 (이 스킬의 기반) |
| `.gitignore` | `.env` 파일 제외 여부 확인 |
| `.env` / `.env.local` / `.env.example` | 환경 변수 파일 (민감 정보 포함 여부 확인) |
