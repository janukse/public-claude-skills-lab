---
name: code-convention-node
description: Node.js 코드 컨벤션 가이드 및 검증. Core(code-convention) 스킬을 확장하여 API 설계, 미들웨어, DB 핵심 규칙을 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# Node.js 코드 컨벤션

## 기반 스킬

이 스킬은 **Core 코드 컨벤션**(`code-convention/SKILL.md`)의 확장입니다.

**적용 우선순위:**
1. 이 스킬(Node.js 확장)의 규칙을 우선 적용
2. Core 스킬의 규칙을 병행 적용
3. 충돌 시 이 스킬의 규칙이 우선

> **Claude에게:** Guide 모드 실행 시, 먼저 `code-convention/SKILL.md`를 읽고 Core 규칙을 숙지한 후 이 스킬의 규칙을 추가 적용하세요. Verify 모드에서는 Core 검증과 Node.js 검증을 모두 수행합니다.

## 확장 스킬

이 스킬은 다음 확장 스킬과 함께 사용할 수 있습니다:

| 확장 스킬 | 설명 |
|-----------|------|
| `code-convention-node-ops/SKILL.md` | 설정 관리(G4), 로깅(G5), 보안(G6) 규칙을 다루는 운영 컨벤션 확장 |

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-node guide` | Node.js 코드 작성 시 규칙 적용 |
| Verify | `/code-convention-node verify src/` | Node.js 코드 검증 + Core 검증 병행 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 보안 취약점, 데이터 손실, 서버 다운 |
| `[Warning]` | 권장 | 성능 저하, 일관성, 유지보수 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

---

## [Guide 모드] Node.js 코드 작성 규칙

### G1. API 설계

#### G1.1 RESTful URL 규칙 [Warning]

**규칙:** URL은 명사 복수형을 사용합니다. 동사는 HTTP 메서드로 표현합니다. 중첩 리소스는 2단계까지만 허용합니다.

**이유:** RESTful 규칙은 API의 예측 가능성과 일관성을 보장합니다.

**Good:**
```typescript
// 명사 복수형 + HTTP 메서드
GET    /api/v1/users
POST   /api/v1/users
GET    /api/v1/users/:id
PATCH  /api/v1/users/:id
DELETE /api/v1/users/:id

// 중첩 리소스 (2단계까지)
GET    /api/v1/users/:userId/orders
POST   /api/v1/users/:userId/orders
```

**Bad:**
```typescript
// 동사 사용
GET  /api/v1/getUsers
POST /api/v1/createUser
POST /api/v1/deleteUser/:id

// 단수형
GET  /api/v1/user

// 과도한 중첩 (3단계 이상)
GET  /api/v1/users/:userId/orders/:orderId/items/:itemId/reviews
```

#### G1.2 HTTP 메서드 사용 기준 [Warning]

**규칙:** HTTP 메서드를 시맨틱에 맞게 사용합니다: GET(조회), POST(생성), PUT(전체 교체), PATCH(부분 수정), DELETE(삭제).

**이유:** 올바른 HTTP 메서드 사용은 캐싱, 멱등성, 안전성의 기대를 충족합니다.

**Good:**
```typescript
// Express/Fastify 라우트 정의
router.get('/users', listUsers);          // 조회 (안전, 멱등)
router.post('/users', createUser);        // 생성 (비멱등)
router.get('/users/:id', getUser);        // 단건 조회
router.patch('/users/:id', updateUser);   // 부분 수정 (멱등)
router.delete('/users/:id', deleteUser);  // 삭제 (멱등)
```

**Bad:**
```typescript
// GET으로 상태 변경
router.get('/users/:id/delete', deleteUser);

// POST로 모든 것을 처리
router.post('/users/search', searchUsers);  // GET + query params가 적합
router.post('/users/:id/update', updateUser);  // PATCH가 적합
```

#### G1.3 응답 포맷 표준화 [Warning]

**규칙:** API 응답은 일관된 포맷을 사용합니다. 성공과 에러 응답의 구조를 통일합니다.

**이유:** 일관된 응답 포맷은 프론트엔드 개발과 API 소비자의 예측 가능성을 높입니다.

**Good:**
```typescript
// 성공 응답
interface SuccessResponse<T> {
  success: true;
  data: T;
  meta?: {
    page: number;
    limit: number;
    total: number;
  };
}

// 에러 응답
interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, string>;
  };
}

// 사용 예
function getUser(req: Request, res: Response) {
  const user = await userService.findById(req.params.id);
  res.json({ success: true, data: user });
}
```

**Bad:**
```typescript
// 응답 포맷 불일치
res.json(user);                          // 엔드포인트 A: 데이터 직접 반환
res.json({ result: user });              // 엔드포인트 B: result 키
res.json({ data: user, status: 'ok' }); // 엔드포인트 C: 또 다른 구조
```

#### G1.4 에러 응답 규칙 [Error]

**규칙:** 에러 응답은 적절한 HTTP 상태 코드와 에러 코드를 포함합니다. 내부 에러 세부정보를 클라이언트에 노출하지 않습니다.

**이유:** 적절한 에러 응답은 디버깅을 돕고, 내부 정보 노출은 보안 위험입니다.

**Good:**
```typescript
// 에러 응답 핸들러
function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        ...(err instanceof ValidationError && { details: err.fields }),
      },
    });
    return;
  }

  // 예상치 못한 에러 — 내부 정보 숨김
  logger.error('Unhandled error', { error: err, requestId: req.id });
  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
    },
  });
}
```

**Bad:**
```typescript
// 내부 에러 세부정보 노출
res.status(500).json({
  error: err.message,        // SQL 에러 메시지 등 노출
  stack: err.stack,           // 스택 트레이스 노출
  query: 'SELECT * FROM...',  // SQL 쿼리 노출
});
```

---

### G2. 미들웨어

#### G2.1 미들웨어 순서 [Warning]

**규칙:** 미들웨어는 다음 순서로 등록합니다: (1) 보안 (helmet, cors) (2) 파싱 (body-parser, cookie) (3) 로깅 (4) 인증 (5) 라우트 (6) 에러 핸들링.

**이유:** 보안 미들웨어가 먼저 적용되어야 모든 요청을 보호하고, 에러 핸들러가 마지막이어야 모든 에러를 잡습니다.

**Good:**
```typescript
const app = express();

// 1. 보안
app.use(helmet());
app.use(cors(corsOptions));

// 2. 파싱
app.use(express.json({ limit: '10mb' }));
app.use(cookieParser());

// 3. 로깅
app.use(requestLogger);

// 4. 인증 (특정 경로에만)
app.use('/api', authMiddleware);

// 5. 라우트
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/products', productRoutes);

// 6. 에러 핸들링 (가장 마지막)
app.use(notFoundHandler);
app.use(errorHandler);
```

**Bad:**
```typescript
const app = express();
app.use('/api', userRoutes);       // 라우트가 보안보다 먼저
app.use(helmet());                 // 보안이 뒤에
app.use(errorHandler);             // 에러 핸들러가 라우트 사이에
app.use('/api', productRoutes);
```

#### G2.2 에러 처리 미들웨어 [Error]

**규칙:** Express 에러 미들웨어는 4개의 매개변수 `(err, req, res, next)`를 가집니다. 비동기 에러도 반드시 catch합니다.

**이유:** 처리되지 않은 에러는 서버 크래시를 유발합니다.

**Good:**
```typescript
// 비동기 핸들러 래퍼
function asyncHandler(fn: RequestHandler): RequestHandler {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

// 사용
router.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await userService.findById(req.params.id);
  if (!user) throw new NotFoundError('User', req.params.id);
  res.json({ success: true, data: user });
}));

// 에러 미들웨어
function errorHandler(err: Error, req: Request, res: Response, _next: NextFunction) {
  // 에러 처리 로직
}
```

**Bad:**
```typescript
// 비동기 에러 미처리 — 서버 크래시 가능
router.get('/users/:id', async (req, res) => {
  const user = await userService.findById(req.params.id); // 에러 시 UnhandledRejection
  res.json(user);
});

// try-catch를 매 핸들러마다 반복
router.get('/users/:id', async (req, res, next) => {
  try {
    const user = await userService.findById(req.params.id);
    res.json(user);
  } catch (error) {
    next(error);
  }
});
```

#### G2.3 인증/인가 분리 [Warning]

**규칙:** 인증(Authentication)과 인가(Authorization)를 별도의 미들웨어로 분리합니다.

**이유:** 관심사 분리로 각 미들웨어를 독립적으로 테스트하고 재사용할 수 있습니다.

**Good:**
```typescript
// 인증 미들웨어 — "누구인가?"
async function authenticate(req: Request, res: Response, next: NextFunction) {
  const token = extractToken(req);
  if (!token) throw new UnauthorizedError('Token required');
  req.user = await verifyToken(token);
  next();
}

// 인가 미들웨어 — "권한이 있는가?"
function authorize(...roles: string[]): RequestHandler {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      throw new ForbiddenError('Insufficient permissions');
    }
    next();
  };
}

// 사용
router.delete('/users/:id', authenticate, authorize('admin'), deleteUser);
```

**Bad:**
```typescript
// 인증과 인가가 혼합
async function authMiddleware(req, res, next) {
  const token = extractToken(req);
  const user = await verifyToken(token);
  if (req.path.includes('/admin') && user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  req.user = user;
  next();
}
```

---

### G3. DB

#### G3.1 쿼리 패턴 [Warning]

**규칙:** SQL 쿼리는 파라미터 바인딩을 사용합니다. 문자열 연결로 쿼리를 구성하지 않습니다. 복잡한 쿼리는 쿼리 빌더나 ORM을 사용합니다.

**이유:** 파라미터 바인딩은 SQL 인젝션을 방지합니다.

**Good:**
```typescript
// 파라미터 바인딩
const user = await db.query('SELECT * FROM users WHERE id = $1', [userId]);

// 쿼리 빌더 (Knex)
const users = await db('users')
  .where({ status: 'active' })
  .whereIn('role', ['admin', 'editor'])
  .orderBy('created_at', 'desc')
  .limit(20);

// ORM (Prisma)
const users = await prisma.user.findMany({
  where: { status: 'active' },
  orderBy: { createdAt: 'desc' },
  take: 20,
});
```

**Bad:**
```typescript
// SQL 인젝션 취약
const user = await db.query(`SELECT * FROM users WHERE id = '${userId}'`);
const users = await db.query(`SELECT * FROM users WHERE name LIKE '%${search}%'`);
```

#### G3.2 ORM/ODM 규칙 [Warning]

**규칙:** ORM 모델은 도메인 모듈별로 분리합니다. 관계(relation)를 명시적으로 정의하고, eager loading과 lazy loading을 의도적으로 선택합니다.

**이유:** N+1 쿼리 문제와 과도한 데이터 로딩을 방지합니다.

**Good:**
```typescript
// Prisma — 명시적 관계 로딩
const userWithOrders = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    orders: {
      where: { status: 'active' },
      take: 10,
      orderBy: { createdAt: 'desc' },
    },
  },
});

// select로 필요한 필드만 조회
const userNames = await prisma.user.findMany({
  select: { id: true, name: true, email: true },
  where: { status: 'active' },
});
```

**Bad:**
```typescript
// N+1 쿼리 문제
const users = await prisma.user.findMany();
for (const user of users) {
  const orders = await prisma.order.findMany({ where: { userId: user.id } });
  // 유저 수만큼 쿼리 발생
}

// 불필요한 전체 데이터 로딩
const users = await prisma.user.findMany({
  include: { orders: true, posts: true, comments: true }, // 모든 관계 로딩
});
```

#### G3.3 마이그레이션 규칙 [Warning]

**규칙:** DB 스키마 변경은 항상 마이그레이션을 통해 수행합니다. 마이그레이션은 롤백 가능해야 합니다. 프로덕션 데이터를 변경하는 마이그레이션은 별도로 관리합니다.

**이유:** 마이그레이션은 스키마 변경 이력을 추적하고, 환경 간 일관성을 보장합니다.

**Good:**
```typescript
// Prisma 마이그레이션
// prisma/migrations/20240101_add_user_status/migration.sql

-- 추가
ALTER TABLE "User" ADD COLUMN "status" TEXT NOT NULL DEFAULT 'active';
CREATE INDEX "User_status_idx" ON "User"("status");

// Knex 마이그레이션
export async function up(knex: Knex) {
  await knex.schema.alterTable('users', (table) => {
    table.string('status').notNullable().defaultTo('active');
    table.index('status');
  });
}

export async function down(knex: Knex) {
  await knex.schema.alterTable('users', (table) => {
    table.dropColumn('status');
  });
}
```

**Bad:**
```typescript
// 마이그레이션 없이 직접 스키마 변경
await db.query('ALTER TABLE users ADD COLUMN status TEXT');

// 롤백 불가능한 마이그레이션
export async function up(knex: Knex) {
  await knex.schema.dropTable('old_users'); // 데이터 손실
}
export async function down(knex: Knex) {
  // 복구 불가
}
```

#### G3.4 트랜잭션 사용 [Warning]

**규칙:** 여러 테이블을 수정하는 작업은 트랜잭션으로 감쌉니다. 트랜잭션은 가능한 짧게 유지합니다.

**이유:** 트랜잭션 없이 다중 쿼리를 실행하면 데이터 불일치가 발생할 수 있습니다.

**Good:**
```typescript
// Prisma 트랜잭션
async function transferMoney(fromId: string, toId: string, amount: number) {
  await prisma.$transaction(async (tx) => {
    const from = await tx.account.update({
      where: { id: fromId },
      data: { balance: { decrement: amount } },
    });

    if (from.balance < 0) {
      throw new InsufficientFundsError();
    }

    await tx.account.update({
      where: { id: toId },
      data: { balance: { increment: amount } },
    });

    await tx.transaction.create({
      data: { fromId, toId, amount, type: 'transfer' },
    });
  });
}
```

**Bad:**
```typescript
// 트랜잭션 없이 다중 수정 — 중간에 실패하면 데이터 불일치
async function transferMoney(fromId: string, toId: string, amount: number) {
  await prisma.account.update({
    where: { id: fromId },
    data: { balance: { decrement: amount } },
  });
  // 여기서 에러 발생하면 출금만 되고 입금은 안 됨!
  await prisma.account.update({
    where: { id: toId },
    data: { balance: { increment: amount } },
  });
}
```

---

## [Verify 모드] Node.js 코드 검증 워크플로우

### Step 1: 검증 대상 수집

Glob 도구를 사용하여 Node.js 소스 파일을 수집합니다:
- 패턴: `**/*.{ts,js}`
- `node_modules/`, `dist/`, `build/` 디렉토리는 제외

### Step 2: Core 검증 병행

Core 스킬(`code-convention/SKILL.md`)의 Verify 워크플로우를 먼저 실행합니다.

### Step 3: G1 API 설계 검사

Grep 도구를 사용하여 탐지합니다:

RESTful URL 규칙 확인:
- 패턴: `router\.(get|post|put|patch|delete)`
- Glob 필터: `*.ts`

동사 기반 URL 탐지:
- 패턴: `router\.\w*['"]\/\w*(get|create|update|delete|fetch)`
- Glob 필터: `*.ts`

에러 응답에서 stack trace 노출:
- 패턴: `(err|error)\.stack`
- Glob 필터: `*.ts`
- 결과에서 `res.` 또는 `json` 또는 `send` 포함 행만 위반

### Step 4: G2 미들웨어 검사

Grep 도구를 사용하여 탐지합니다:

비동기 핸들러 에러 처리 확인:
- 패턴: `router\.(get|post|put|patch|delete).*async`
- Glob 필터: `*.ts`

에러 미들웨어 존재 확인 (4개 파라미터):
- 패턴: `(err|error).*req.*res.*next`
- Glob 필터: `*.ts`

### Step 5: G3 DB 검사

Grep 도구를 사용하여 탐지합니다:

SQL 인젝션 취약점 (문자열 보간 쿼리):
- 패턴 1: `query\(` + 결과에서 `\$\{` 포함 행
- 패턴 2: `query\(` + 결과에서 `+` 포함 행 (문자열 연결)
- Glob 필터: `*.ts`
- **면제:** ORM 메서드 호출 (Prisma의 `$queryRaw`에서 `Prisma.sql` 태그드 템플릿 사용은 안전)
- **면제:** 쿼리 빌더 메서드 체이닝 (`knex`, `typeorm`의 `.where()` 등)

N+1 쿼리 패턴 (루프 내 쿼리):
- 패턴: `for.*await.*(find|query)|forEach.*await`
- Glob 필터: `*.ts`
- **면제:** 배치 크기가 제한된 경우 (예: `slice`, `chunk` 등으로 제한된 루프)
- **면제:** 마이그레이션/시드 스크립트 파일

### Step 6: 보고서 생성

Core 검증 결과와 Node.js 검증 결과를 통합하여 보고서를 출력합니다.

```markdown
## Node.js 코드 컨벤션 검증 보고서

**검증 대상:** <경로>
**검증 일시:** <날짜>
**적용 규칙:** Core + Node.js Core

### 요약

| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| Core: G1-G5 | ... | ... | ... | ... |
| Node Core: G1. API 설계 | 0 | 1 | 0 | ⚠️ |
| Node Core: G2. 미들웨어 | 1 | 0 | 0 | ❌ |
| Node Core: G3. DB | 0 | 2 | 0 | ⚠️ |

### 상세 위반 목록

| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
| 1 | Error | G2.2 | src/routes/user.ts | 15 | async 핸들러 에러 미처리 | asyncHandler 래퍼 적용 |
| ... | | | | | | |
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **CLI 스크립트** — 일회성 실행 스크립트에서의 `console.log` 사용
2. **테스트 환경** — 테스트에서의 하드코딩된 설정값, `process.env` 직접 설정
3. **프레임워크 컨벤션** — NestJS의 데코레이터 패턴, Fastify의 플러그인 시스템 등
4. **시드/마이그레이션 스크립트** — DB 시드 데이터의 하드코딩된 값
5. **서버리스 함수** — Lambda/Cloud Functions의 특수 핸들러 패턴

## Related Files

| File | Purpose |
|------|---------|
| `code-convention/SKILL.md` | Core 규칙 (이 스킬의 기반) |
| `code-convention-node-ops/SKILL.md` | 운영 확장 (설정 관리, 로깅, 보안 규칙) |
| `package.json` | 프로젝트 의존성 (Express, Fastify, Prisma 등) |
| `.env` / `.env.example` | 환경 변수 정의 |
| `prisma/schema.prisma` | Prisma 스키마 (사용 시) |
| `docker-compose.yml` | Docker 설정 (사용 시) |
