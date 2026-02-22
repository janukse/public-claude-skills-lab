---
name: code-convention-node-ops
description: Node.js 운영 컨벤션 가이드 및 검증. Node.js Core(code-convention-node) 스킬을 확장하여 설정 관리, 로깅, 보안 규칙을 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# Node.js 운영 컨벤션

## 기반 스킬

이 스킬은 **Core 코드 컨벤션**(`code-convention/SKILL.md`)과 **Node.js Core 컨벤션**(`code-convention-node/SKILL.md`)의 확장입니다.

**적용 우선순위:**
1. 이 스킬(Node.js 운영 확장)의 규칙을 우선 적용
2. Node.js Core 스킬의 규칙을 병행 적용
3. Core 스킬의 규칙을 병행 적용
4. 충돌 시 이 스킬 > Node.js Core > Core 순으로 우선

> **Claude에게:** Guide 모드 실행 시, 먼저 `code-convention/SKILL.md`(Core 규칙)와 `code-convention-node/SKILL.md`(Node.js Core 규칙)를 읽고 숙지한 후 이 스킬의 규칙을 추가 적용하세요. Verify 모드에서는 Core 검증, Node.js Core 검증, 그리고 이 스킬의 운영 검증을 모두 수행합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-node-ops guide` | Node.js 운영 코드 작성 시 규칙 적용 |
| Verify | `/code-convention-node-ops verify src/` | Node.js 운영 코드 검증 + Node Core 검증 + Core 검증 병행 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 보안 취약점, 데이터 손실, 서버 다운 |
| `[Warning]` | 권장 | 성능 저하, 일관성, 유지보수 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

---

## [Guide 모드] Node.js 운영 코드 작성 규칙

### G4. 설정 관리

#### G4.1 환경 변수 검증 [Error]

**규칙:** 환경 변수는 애플리케이션 시작 시 스키마로 검증합니다. 검증 실패 시 즉시 종료합니다.

**이유:** 런타임에 환경 변수 누락을 발견하면 예측 불가능한 동작이 발생합니다.

**Good:**
```typescript
// config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('7d'),
  CORS_ORIGINS: z.string().transform((s) => s.split(',')),
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
});

export const env = envSchema.parse(process.env);
export type Env = z.infer<typeof envSchema>;
```

**Bad:**
```typescript
// 검증 없이 직접 사용
const port = process.env.PORT || 3000;
const dbUrl = process.env.DATABASE_URL!; // non-null assertion — 위험
const secret = process.env.JWT_SECRET; // undefined일 수 있음
```

#### G4.2 설정 모듈화 [Warning]

**규칙:** 설정은 도메인별로 모듈화하여 관리합니다. 환경 변수를 직접 참조하지 않고 설정 객체를 통해 접근합니다.

**이유:** 설정 모듈화는 테스트 시 설정 교체와 환경별 오버라이드를 용이하게 합니다.

**Good:**
```typescript
// config/database.ts
import { env } from './env';

export const databaseConfig = {
  url: env.DATABASE_URL,
  pool: {
    min: env.NODE_ENV === 'production' ? 5 : 1,
    max: env.NODE_ENV === 'production' ? 20 : 5,
  },
  logging: env.NODE_ENV !== 'production',
};

// config/index.ts
export { env } from './env';
export { databaseConfig } from './database';
export { authConfig } from './auth';
export { corsConfig } from './cors';
```

**Bad:**
```typescript
// 서비스 코드에서 환경 변수 직접 참조
class UserService {
  async connect() {
    await db.connect(process.env.DATABASE_URL); // 직접 참조
  }
}
```

#### G4.3 Secret 관리 [Error]

**규칙:** 시크릿(API 키, DB 비밀번호 등)은 환경 변수 또는 시크릿 매니저를 통해 주입합니다. 코드, 설정 파일, Docker 이미지에 하드코딩하지 않습니다.

**이유:** 하드코딩된 시크릿은 버전 관리 시스템과 컨테이너 이미지를 통해 유출됩니다.

**Good:**
```typescript
// .env (gitignore에 등록)
JWT_SECRET=your-secret-key-here
STRIPE_API_KEY=sk_live_xxxxx

// docker-compose.yml
services:
  app:
    environment:
      - JWT_SECRET=${JWT_SECRET}
    secrets:
      - db_password

// 시크릿 매니저 사용 (AWS, GCP, etc.)
import { SecretsManager } from '@aws-sdk/client-secrets-manager';
```

**Bad:**
```typescript
// 코드에 하드코딩
const JWT_SECRET = 'my-super-secret-key-12345';

// Dockerfile에 하드코딩
// ENV JWT_SECRET=my-secret

// 설정 파일에 포함 (git에 커밋됨)
// config/production.json
// { "jwtSecret": "my-secret" }
```

---

### G5. 로깅

#### G5.1 로그 레벨 [Warning]

**규칙:** 로그 레벨을 적절히 사용합니다: `error` (장애), `warn` (잠재적 문제), `info` (주요 이벤트), `debug` (개발 디버깅). `console.log`를 프로덕션 코드에서 사용하지 않습니다.

**이유:** 올바른 로그 레벨은 프로덕션에서 노이즈 없이 필요한 정보를 제공합니다.

**Good:**
```typescript
import { logger } from '@/lib/logger';

// error — 즉시 대응 필요
logger.error('Payment processing failed', { orderId, error });

// warn — 잠재적 문제
logger.warn('Rate limit approaching', { userId, currentRate });

// info — 주요 비즈니스 이벤트
logger.info('User registered', { userId, method: 'email' });

// debug — 개발 시 디버깅
logger.debug('Cache hit', { key, ttl });
```

**Bad:**
```typescript
// console.log 사용
console.log('User created:', user);        // 구조화되지 않은 로그
console.error('Something went wrong');     // 맥락 정보 없음

// 부적절한 레벨
logger.error('User logged in');           // info가 적합
logger.info('Database connection failed'); // error가 적합
```

#### G5.2 구조화된 로깅 [Warning]

**규칙:** 로그는 JSON 형태의 구조화된 포맷을 사용합니다. 문자열 연결 대신 메타데이터 객체를 전달합니다.

**이유:** 구조화된 로그는 로그 수집/분석 도구에서 검색과 필터링이 용이합니다.

**Good:**
```typescript
// 구조화된 로거 설정 (pino, winston 등)
import pino from 'pino';

export const logger = pino({
  level: env.LOG_LEVEL,
  transport: env.NODE_ENV === 'development'
    ? { target: 'pino-pretty' }
    : undefined,
});

// 구조화된 로그 출력
logger.info({
  msg: 'Order completed',
  orderId: order.id,
  userId: order.userId,
  total: order.total,
  items: order.items.length,
  duration: Date.now() - startTime,
});
```

**Bad:**
```typescript
// 문자열 연결 로그
logger.info(`Order ${orderId} completed by user ${userId} for $${total}`);
// → 파싱 불가, 필터링 어려움

// 민감 정보 로깅
logger.info('Login attempt', { email, password }); // 비밀번호 로깅!
```

#### G5.3 Correlation ID [Info]

**규칙:** 요청별 고유 ID(correlation ID / request ID)를 생성하여 모든 로그에 포함합니다.

**이유:** 분산 시스템에서 하나의 요청 흐름을 추적할 수 있습니다.

**Good:**
```typescript
import { randomUUID } from 'node:crypto';
import { AsyncLocalStorage } from 'node:async_hooks';

const requestContext = new AsyncLocalStorage<{ requestId: string }>();

// 미들웨어
function requestIdMiddleware(req: Request, res: Response, next: NextFunction) {
  const requestId = req.headers['x-request-id'] as string || randomUUID();
  res.setHeader('x-request-id', requestId);

  requestContext.run({ requestId }, () => next());
}

// 로거에서 자동 포함
const logger = pino({
  mixin() {
    const store = requestContext.getStore();
    return store ? { requestId: store.requestId } : {};
  },
});
```

**Bad:**
```typescript
// requestId 없이 로깅
logger.info('Request received');
logger.info('Database query executed');
logger.error('Request failed');
// → 어떤 요청의 로그인지 추적 불가
```

---

### G6. 보안

#### G6.1 입력 검증 (서버) [Error]

**규칙:** 모든 API 입력(body, query, params, headers)을 스키마로 검증합니다. 검증은 컨트롤러 진입 시점에서 수행합니다.

**이유:** 서버는 클라이언트 검증을 신뢰할 수 없으며, 검증되지 않은 입력은 인젝션 공격을 유발합니다.

**Good:**
```typescript
import { z } from 'zod';

const CreateUserSchema = z.object({
  body: z.object({
    name: z.string().min(1).max(100),
    email: z.string().email(),
    role: z.enum(['user', 'editor']).default('user'),
  }),
  params: z.object({}),
  query: z.object({}),
});

// 미들웨어로 검증
function validate<T extends z.ZodSchema>(schema: T): RequestHandler {
  return (req, res, next) => {
    const result = schema.safeParse({
      body: req.body,
      params: req.params,
      query: req.query,
    });

    if (!result.success) {
      throw new ValidationError('Invalid input', result.error.flatten().fieldErrors);
    }

    req.validated = result.data;
    next();
  };
}

router.post('/users', validate(CreateUserSchema), createUser);
```

**Bad:**
```typescript
// 검증 없이 직접 사용
router.post('/users', (req, res) => {
  const { name, email, role } = req.body; // 어떤 값이든 통과
  await userService.create({ name, email, role });
});
```

#### G6.2 Rate Limiting [Warning]

**규칙:** 공개 API에 rate limiting을 적용합니다. 인증 엔드포인트에는 더 엄격한 제한을 적용합니다.

**이유:** Rate limiting은 브루트포스 공격과 서비스 남용을 방지합니다.

**Good:**
```typescript
import rateLimit from 'express-rate-limit';

// 일반 API 제한
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15분
  max: 100,
  standardHeaders: true,
  message: { success: false, error: { code: 'RATE_LIMITED', message: 'Too many requests' } },
});

// 인증 API 제한 (더 엄격)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  skipSuccessfulRequests: true, // 성공한 요청은 카운트하지 않음
});

app.use('/api', apiLimiter);
app.use('/api/auth', authLimiter);
```

**Bad:**
```typescript
// rate limiting 없이 공개 API 노출
app.use('/api', routes); // 무제한 요청 허용
```

#### G6.3 CORS 설정 [Warning]

**규칙:** CORS는 허용된 origin을 명시적으로 지정합니다. 와일드카드(`*`)는 공개 API에서만 사용합니다.

**이유:** 넓은 CORS 설정은 CSRF 공격의 벡터를 넓힙니다.

**Good:**
```typescript
import cors from 'cors';

const corsOptions: CorsOptions = {
  origin: env.CORS_ORIGINS, // ['https://example.com', 'https://app.example.com']
  methods: ['GET', 'POST', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400, // preflight 캐싱 24시간
};

app.use(cors(corsOptions));
```

**Bad:**
```typescript
// 모든 origin 허용
app.use(cors()); // origin: '*', credentials 불가

// credentials와 와일드카드 동시 사용 시도
app.use(cors({ origin: '*', credentials: true })); // 브라우저에서 차단
```

#### G6.4 보안 헤더 [Warning]

**규칙:** `helmet` 미들웨어를 사용하여 보안 헤더를 설정합니다. CSP(Content Security Policy)를 프로젝트에 맞게 설정합니다.

**이유:** 보안 헤더는 XSS, 클릭재킹, MIME 스니핑 등 일반적인 웹 공격을 방지합니다.

**Good:**
```typescript
import helmet from 'helmet';

app.use(helmet());

// CSP 커스터마이징이 필요한 경우
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
}));
```

**Bad:**
```typescript
// 보안 헤더 없음
const app = express();
app.use(express.json());
app.use('/api', routes);
// → X-Content-Type-Options, X-Frame-Options 등 미설정

// helmet을 비활성화
app.use(helmet({ contentSecurityPolicy: false })); // CSP 비활성화
```

#### G6.5 암호학적 안전한 난수 생성 [Error]

**규칙:** 세션 ID, 토큰, nonce, 비밀번호 솔트 등 보안 관련 난수는 `node:crypto` 모듈을 사용합니다. `Math.random()`은 보안 목적에 사용하지 않습니다.

**이유:** `Math.random()`은 예측 가능한 의사 난수 생성기로, 서버에서 세션 ID나 토큰 생성에 사용하면 세션 하이재킹, 토큰 위조 등 심각한 보안 취약점이 됩니다.

**Good:**
```typescript
import { randomBytes, randomUUID, scrypt } from 'node:crypto';

// 세션 토큰 생성
const sessionToken = randomBytes(32).toString('hex');

// 요청 ID 생성
const requestId = randomUUID();

// 비밀번호 솔트 생성
const salt = randomBytes(16).toString('hex');

// 비밀번호 해싱
async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16);
  return new Promise((resolve, reject) => {
    scrypt(password, salt, 64, (err, derivedKey) => {
      if (err) reject(err);
      resolve(`${salt.toString('hex')}:${derivedKey.toString('hex')}`);
    });
  });
}

// API 키 생성
const apiKey = `sk_${randomBytes(24).toString('base64url')}`;
```

**Bad:**
```typescript
// Math.random()으로 토큰 생성 — 예측 가능!
const sessionId = Math.random().toString(36).substring(2);
const token = `tok_${Math.random().toString(36)}`;

// Date 기반 ID — 충돌 및 예측 가능
const requestId = `req_${Date.now()}_${Math.random()}`;

// 자체 난수 시드 사용
function generateToken(seed: number): string {
  return ((seed * 16807) % 2147483647).toString(36); // 암호학적으로 불안전
}
```

#### G6.6 민감 데이터 메모리 관리 [Warning]

**규칙:** 비밀번호, 암호화 키, 토큰 등 민감 데이터를 `Buffer`로 다루고, 사용 후 즉시 `fill(0)`으로 제로화합니다. 비밀번호 비교에는 `timingSafeEqual`을 사용합니다.

**이유:** 메모리에 남아 있는 민감 데이터는 메모리 덤프, 코어 덤프, 프로세스 포크를 통해 유출될 수 있습니다. 일반 문자열 비교(`===`)는 타이밍 공격에 취약합니다.

**Good:**
```typescript
import { timingSafeEqual, scrypt } from 'node:crypto';

// 비밀번호 검증 — timingSafeEqual + 제로화
async function verifyPassword(input: string, stored: string): Promise<boolean> {
  const [salt, hash] = stored.split(':');
  const saltBuffer = Buffer.from(salt, 'hex');
  const storedHash = Buffer.from(hash, 'hex');

  return new Promise((resolve, reject) => {
    scrypt(input, saltBuffer, 64, (err, derivedKey) => {
      if (err) reject(err);
      try {
        resolve(timingSafeEqual(derivedKey, storedHash));
      } finally {
        derivedKey.fill(0); // 파생 키 제로화
        saltBuffer.fill(0); // 솔트 제로화
      }
    });
  });
}

// 암호화 키 사용 후 제로화
async function encryptAndCleanup(data: Buffer, key: Buffer): Promise<Buffer> {
  try {
    return await encrypt(data, key);
  } finally {
    key.fill(0);
  }
}
```

**Bad:**
```typescript
// 문자열 비교 — 타이밍 공격 취약
function verifyPassword(input: string, stored: string): boolean {
  return input === stored; // 문자 길이에 따라 응답 시간이 다름
}

// 키가 메모리에 계속 남아 있음
const secretKey = Buffer.from(env.ENCRYPTION_KEY, 'hex');
const result = encrypt(data, secretKey);
// secretKey가 제로화되지 않고 GC까지 메모리에 잔류

// 에러 로그에 민감 데이터 포함
logger.error('Auth failed', { password: input, hash: stored });
```

---

## [Verify 모드] Node.js 운영 코드 검증 워크플로우

### Step 1: 검증 대상 수집

Glob 도구를 사용하여 Node.js 소스 파일을 수집합니다:
- 패턴: `**/*.{ts,js}`
- `node_modules/`, `dist/`, `build/` 디렉토리는 제외

### Step 2: Core 및 Node Core 검증 병행

Core 스킬(`code-convention/SKILL.md`)과 Node.js Core 스킬(`code-convention-node/SKILL.md`)의 Verify 워크플로우를 먼저 실행합니다.

### Step 3: G4 설정 검사

Grep 도구를 사용하여 탐지합니다:

process.env 직접 참조 (config 모듈 외부):
- 패턴: `process\.env\.`
- Glob 필터: `*.ts`
- `config`, `env.ts`, `env.js` 파일은 면제 처리

.env가 .gitignore에 있는지 확인:
- 패턴: `\.env`
- 경로: `.gitignore`

하드코딩된 시크릿:
- 패턴: `secret.*=.*['"].{10,}['"]`
- Glob 필터: `*.ts`
- test/spec/mock/example 파일은 면제 처리

### Step 4: G5 로깅 검사

Grep 도구를 사용하여 탐지합니다:

console 사용 (프로덕션 코드에서):
- 패턴: `console\.(log|error|warn|info)`
- Glob 필터: `*.ts`
- **면제:** test/spec 파일
- **면제:** CLI 스크립트 (`scripts/`, `bin/`, `cli.ts` 등)
- **면제:** 개발 전용 설정 파일 (`*.config.ts`)

민감 정보 로깅:
- 패턴: `log.*(password|secret|token|key)`
- Glob 필터: `*.ts`
- 대소문자 무시 옵션 사용
- **면제:** `key`가 일반 객체 키를 의미하는 경우 (예: `queryKey`, `primaryKey`, `sortKey`)
- **면제:** 타입 정의/인터페이스 행

### Step 5: G6.5/G6.6 보안 심화 검사

Grep 도구를 사용하여 탐지합니다:

Math.random()을 보안 목적에 사용하는 패턴:
- 패턴: `Math\.random\(\)`
- Glob 필터: `*.ts`
- test/spec/mock 파일은 면제 처리

crypto 모듈 미사용 확인 (토큰/세션 생성 파일에서):
- 패턴: `token|session|nonce|salt`
- Glob 필터: `*.ts`
- 매칭된 파일에 `node:crypto` 또는 `crypto` import가 없으면 위반
- **면제:** `token`이 인증 토큰 생성이 아닌 파싱/검증만 하는 파일 (예: JWT decode, OAuth callback)
- **면제:** `session`이 Express session 미들웨어 설정만 하는 파일
- **면제:** 타입/인터페이스 정의 파일 (`.d.ts`, `types.ts`)

문자열 비교로 비밀번호 검증하는 패턴:
- 패턴: `password.*===|===.*password`
- Glob 필터: `*.ts`
- test/spec 파일은 면제 처리

timingSafeEqual 사용 확인 (비밀번호/토큰 검증 파일에서):
- 패턴: `verify|compare|authenticate`
- Glob 필터: `*.ts`
- 매칭된 파일에 `timingSafeEqual`이 없으면 경고

### Step 6: 보고서 생성

Core 검증, Node.js Core 검증, 운영 검증 결과를 통합하여 보고서를 출력합니다.

```markdown
## Node.js 운영 컨벤션 검증 보고서

**검증 대상:** <경로>
**검증 일시:** <날짜>
**적용 규칙:** Core + Node.js Core + Node.js Ops

### 요약

| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| Core: G1-G5 | ... | ... | ... | ... |
| Node Core: G1-G3 | ... | ... | ... | ... |
| Node Ops: G4. 설정 관리 | 1 | 0 | 0 | ❌ |
| Node Ops: G5. 로깅 | 0 | 1 | 0 | ⚠️ |
| Node Ops: G6. 보안 | 0 | 1 | 0 | ⚠️ |

### 상세 위반 목록

| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
| 1 | Error | G4.1 | src/index.ts | 3 | 환경 변수 검증 누락 | Zod 스키마 검증 추가 |
| ... | | | | | | |
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **CLI 스크립트** — 일회성 실행 스크립트에서의 `console.log` 사용
2. **테스트 환경** — 테스트에서의 하드코딩된 설정값, `process.env` 직접 설정
3. **프레임워크 컨벤션** — NestJS의 데코레이터 패턴, Fastify의 플러그인 시스템 등
4. **시드/마이그레이션 스크립트** — DB 시드 데이터의 하드코딩된 값
5. **개발 전용 도구** — 개발 서버 설정, devDependencies의 도구 설정
6. **서버리스 함수** — Lambda/Cloud Functions의 특수 핸들러 패턴

## Related Files

| File | Purpose |
|------|---------|
| `code-convention/SKILL.md` | Core 규칙 (기반 스킬) |
| `code-convention-node/SKILL.md` | Node.js Core 규칙 (기반 스킬) |
| `package.json` | 프로젝트 의존성 (Express, Fastify, Prisma 등) |
| `.env` / `.env.example` | 환경 변수 정의 |
| `src/config/` | 설정 모듈 디렉토리 |
| `docker-compose.yml` | Docker 설정 (사용 시) |
