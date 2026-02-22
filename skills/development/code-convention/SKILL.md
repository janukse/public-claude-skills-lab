---
name: code-convention
description: TypeScript/JavaScript 코드 컨벤션 Core 핵심 규칙(G1-G5). 네이밍, 타입, 함수, Import/Export, 에러 처리의 시맨틱 규칙을 안내(Guide)하거나 검증(Verify)합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# TypeScript/JavaScript 코드 컨벤션

## 목적

TypeScript/JavaScript 프로젝트에서 일관된 코드 품질을 유지하기 위한 **시맨틱 규칙** 시스템입니다:

1. **Guide 모드** — 코드 작성 시 컨벤션을 자동으로 따르도록 안내
2. **Verify 모드** — 기존 코드의 컨벤션 준수 여부를 검증하고 보고서 생성

ESLint/Prettier가 처리하는 포매팅(들여쓰기, 세미콜론, 줄바꿈 등)은 제외하고, **의미론적 규칙**에 집중합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention guide` | 코드 작성 시 규칙을 참조하여 적용 |
| Verify | `/code-convention verify src/` | 지정 경로의 코드를 검증하고 보고서 출력 |
| Verify (전체) | `/code-convention verify` | 프로젝트 전체 검증 |

## 확장 스킬

이 스킬은 **Core (TS/JS 공통 핵심 규칙 G1-G5)** 를 다룹니다. 추가 규칙과 프레임워크별 규칙은 확장 스킬을 사용하세요:

| 스킬 | 대상 | 설명 |
|------|------|------|
| `code-convention-quality` | 품질/협업 | G6 주석/문서화, G7 테스트, G8 Git/협업 |
| `code-convention-security` | 보안 | G9 보안 (XSS, 입력 검증, 환경 변수, 비밀키 등) |
| `code-convention-react` | React | 컴포넌트, Hooks, 상태관리, 성능 |
| `code-convention-vue3` | Vue 3 | SFC, Composition API, Pinia, Router |
| `code-convention-node` | Node.js | API 설계, 미들웨어, DB, 보안 |

확장 스킬은 이 Core 스킬의 규칙을 상속하며, 충돌 시 확장 스킬의 규칙이 우선합니다.

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 버그, 보안 취약점, 유지보수 심각 저해 |
| `[Warning]` | 권장 | 가독성, 일관성, 팀 협업에 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

---

## [Guide 모드] 코드 작성 규칙

### G1. 네이밍

#### G1.1 변수/함수 네이밍 (camelCase) [Error]

**규칙:** 변수와 함수는 camelCase를 사용합니다.

**이유:** JavaScript/TypeScript 생태계의 표준 컨벤션이며, 일관성을 유지합니다.

**Good:**
```typescript
const userName = 'Alice';
function getUserProfile(userId: string) { /* ... */ }
const handleClick = () => { /* ... */ };
```

**Bad:**
```typescript
const user_name = 'Alice';
function GetUserProfile(userId: string) { /* ... */ }
const handle_click = () => { /* ... */ };
```

#### G1.2 상수 네이밍 (UPPER_SNAKE_CASE) [Warning]

**규칙:** 모듈 수준의 불변 상수는 UPPER_SNAKE_CASE를 사용합니다.

**이유:** 변경되지 않는 값임을 시각적으로 명확히 구분합니다.

**Good:**
```typescript
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = '/api/v1';
const DEFAULT_TIMEOUT_MS = 5000;
```

**Bad:**
```typescript
const maxRetryCount = 3;
const apiBaseUrl = '/api/v1';
```

#### G1.3 클래스/타입/인터페이스 네이밍 (PascalCase) [Error]

**규칙:** 클래스, 타입, 인터페이스, enum은 PascalCase를 사용합니다.

**이유:** 타입과 값을 구분하는 TypeScript 표준 컨벤션입니다.

**Good:**
```typescript
class UserService { /* ... */ }
interface UserProfile { /* ... */ }
type ApiResponse<T> = { data: T; error?: string };
enum UserRole { Admin, Member, Guest }
```

**Bad:**
```typescript
class userService { /* ... */ }
interface userProfile { /* ... */ }
type apiResponse<T> = { data: T; error?: string };
```

#### G1.4 Boolean 변수 접두사 [Warning]

**규칙:** Boolean 변수와 함수는 `is`, `has`, `can`, `should` 등의 접두사를 사용합니다.

**이유:** 변수가 boolean임을 명확히 드러내어 가독성을 높입니다.

**Good:**
```typescript
const isLoading = true;
const hasPermission = user.role === 'admin';
const canEdit = hasPermission && !isLocked;
function shouldRetry(error: Error): boolean { /* ... */ }
```

**Bad:**
```typescript
const loading = true;
const permission = user.role === 'admin';
const edit = permission && !locked;
```

#### G1.5 약어 사용 제한 [Warning]

**규칙:** 널리 알려진 약어(URL, API, ID, HTML 등)를 제외하고, 축약된 이름을 사용하지 않습니다.

**이유:** 약어는 맥락을 모르는 개발자에게 혼동을 줄 수 있습니다.

**Good:**
```typescript
const userMessage = 'Hello';
const buttonElement = document.querySelector('button');
const errorResponse = await fetchData();
```

**Bad:**
```typescript
const usrMsg = 'Hello';
const btnEl = document.querySelector('button');
const errResp = await fetchData();
```

#### G1.6 파일명 컨벤션 [Warning]

**규칙:** 파일명은 kebab-case를 기본으로 하되, 컴포넌트 파일은 PascalCase를 허용합니다. 테스트 파일은 `.test.ts` 또는 `.spec.ts` 접미사를 사용합니다.

**이유:** 파일명의 일관성은 프로젝트 탐색과 import 경로 관리에 도움됩니다.

**Good:**
```
src/utils/date-format.ts
src/services/user-service.ts
src/components/UserProfile.tsx    # 컴포넌트는 PascalCase 허용
src/hooks/use-auth.ts
tests/user-service.test.ts
```

**Bad:**
```
src/utils/dateFormat.ts
src/services/UserService.ts       # 컴포넌트가 아닌 파일에 PascalCase
src/hooks/useAuth.ts
tests/userServiceTest.ts
```

---

### G2. 타입 (TypeScript)

#### G2.1 any 타입 사용 금지 [Error]

**규칙:** `any` 타입을 사용하지 않습니다. 불가피한 경우 `unknown`을 사용하고 타입 가드를 통해 좁힙니다.

**이유:** `any`는 TypeScript의 타입 검사를 무력화하여 런타임 에러를 유발합니다.

**Good:**
```typescript
function parseJson(text: string): unknown {
  return JSON.parse(text);
}

function isUser(value: unknown): value is User {
  return typeof value === 'object' && value !== null && 'name' in value;
}
```

**Bad:**
```typescript
function parseJson(text: string): any {
  return JSON.parse(text);
}

function processData(data: any) {
  return data.name.toUpperCase(); // 런타임 에러 가능
}
```

#### G2.2 interface vs type 사용 기준 [Info]

**규칙:** 객체 형태의 타입 정의에는 `interface`를, 유니온/인터섹션/유틸리티 타입에는 `type`을 사용합니다.

**이유:** `interface`는 선언 병합과 확장에 유리하고, `type`은 복합 타입 표현에 적합합니다.

**Good:**
```typescript
// 객체 형태 → interface
interface User {
  id: string;
  name: string;
  email: string;
}

// 유니온/복합 타입 → type
type Status = 'active' | 'inactive' | 'pending';
type ApiResult<T> = { data: T } | { error: string };
type UserWithPosts = User & { posts: Post[] };
```

**Bad:**
```typescript
// 단순 객체에 type 사용 (interface가 더 적합)
type User = {
  id: string;
  name: string;
};

// 유니온에 interface 사용 불가
// interface Status = 'active' | 'inactive'; // 에러
```

#### G2.3 enum 사용 기준 [Warning]

**규칙:** `const enum`을 피하고, 문자열 리터럴 유니온 또는 `as const` 객체를 우선 사용합니다. 트리셰이킹에 유리하고 번들 크기를 줄입니다.

**Good:**
```typescript
type Direction = 'up' | 'down' | 'left' | 'right'; // 문자열 유니온
const HTTP_STATUS = { OK: 200, NOT_FOUND: 404 } as const; // as const 매핑
```

**Bad:** `enum Direction { Up = 'up', ... }` (오버엔지니어링), `const enum` (번들러 이슈)

#### G2.4 제네릭 타입 매개변수 네이밍 [Info]

**규칙:** 제네릭 타입 매개변수는 의미 있는 이름을 사용합니다. 단일 매개변수이고 문맥이 명확한 경우 `T`를 허용합니다.

**Good:** `merge<TSource, TTarget>(...)`, `Repository<TEntity, TId>`
**Bad:** `merge<T, U>(...)`, `Repository<T, K>` — 복잡한 제네릭에서 의미 불명

#### G2.5 유틸리티 타입 활용 [Info]

**규칙:** TypeScript 내장 유틸리티 타입(`Partial`, `Pick`, `Omit`, `Record` 등)을 적극 활용합니다. 원본 타입과의 동기화를 보장합니다.

**Good:** `type CreateUserInput = Omit<User, 'id'>`, `type UpdateUserInput = Partial<Pick<User, 'name' | 'email'>>`
**Bad:** 수동으로 `interface CreateUserInput { name: string; email: string; }` 재정의 → 동기화 누락 위험

#### G2.6 strict 모드 활성화 [Error]

**규칙:** `tsconfig.json`에서 `"strict": true`를 활성화합니다. `strictNullChecks`, `noImplicitAny` 등을 포함하여 타입 안전성을 극대화합니다.

**Good:** `{ "compilerOptions": { "strict": true } }`
**Bad:** `"strict": false` 또는 `"noImplicitAny": false`

---

### G3. 함수

#### G3.1 단일 책임 원칙 [Error]

**규칙:** 함수는 하나의 역할만 수행합니다. 함수 본문이 30줄을 초과하면 분리를 검토합니다.

**이유:** 단일 책임 함수는 테스트, 재사용, 이해가 쉽습니다.

**Good:**
```typescript
function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

function createUser(input: CreateUserInput): User {
  if (!validateEmail(input.email)) {
    throw new InvalidEmailError(input.email);
  }
  return { id: generateId(), ...input };
}
```

**Bad:**
```typescript
function createUser(input: CreateUserInput): User {
  // 이메일 검증 + 사용자 생성 + 알림 발송 + 로깅을 한 함수에서
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(input.email)) { throw new Error('Invalid email'); }
  const user = { id: generateId(), ...input };
  sendWelcomeEmail(user);
  logger.info('User created', user);
  analytics.track('user_created', user);
  return user;
}
```

#### G3.2 매개변수 개수 제한 [Warning]

**규칙:** 함수 매개변수는 3개 이하로 제한합니다. 그 이상이면 객체 매개변수를 사용합니다. 호출 시 순서 실수를 방지합니다.

**Good:**
```typescript
interface SearchOptions { query: string; page: number; limit: number; sortBy?: string; }
function searchUsers(options: SearchOptions): Promise<User[]> { /* ... */ }
```

**Bad:**
```typescript
function searchUsers(query: string, page: number, limit: number, sortBy: string, order: string): Promise<User[]> { /* ... */ }
```

#### G3.3 Early Return 패턴 [Warning]

**규칙:** Guard clause를 사용하여 조기 반환하고, 중첩 if-else를 피합니다.

**이유:** Early return은 코드의 인지 복잡도를 낮추고 핵심 로직에 집중하게 합니다.

**Good:**
```typescript
function getDiscount(user: User): number {
  if (!user.isActive) return 0;
  if (!user.isPremium) return 5;
  if (user.yearsOfMembership > 5) return 25;
  return 15;
}
```

**Bad:**
```typescript
function getDiscount(user: User): number {
  let discount = 0;
  if (user.isActive) {
    if (user.isPremium) {
      if (user.yearsOfMembership > 5) {
        discount = 25;
      } else {
        discount = 15;
      }
    } else {
      discount = 5;
    }
  }
  return discount;
}
```

#### G3.4 순수 함수 선호 [Info]

**규칙:** 가능한 한 부수 효과가 없는 순수 함수를 작성합니다. 부수 효과가 필요한 경우 함수명으로 명시합니다 (예: `saveAndNotifyUser`).

**Good:** `calculateTotal(items)` → 외부 상태 변경 없이 결과만 반환
```typescript
function calculateTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
```

**Bad:** 외부 변수 `total`을 변경 → 부수 효과
```typescript
let total = 0;
function addToTotal(item: CartItem): number { total += item.price * item.quantity; return total; }
```

#### G3.5 arrow function vs function 선언 [Info]

**규칙:** 최상위 함수는 `function` 선언 (호이스팅), 콜백/인라인은 arrow function (`this` 바인딩 방지).

**Good:** `function processOrder(order: Order) { ... }` + `users.filter((u) => u.isActive)`
**Bad:** `const processOrder = (order: Order) => { ... };` (최상위에 arrow → 호이스팅 불가)

---

### G4. Import/Export

#### G4.1 Import 정렬 [Warning]

**규칙:** Import문은 다음 순서로 그룹화하고 빈 줄로 구분합니다: (1) 외부 패키지 (2) 내부 절대 경로 (3) 상대 경로 (4) 타입 import.

**이유:** 일관된 import 순서는 의존성을 빠르게 파악할 수 있게 합니다.

**Good:**
```typescript
import { useState, useEffect } from 'react';
import { z } from 'zod';

import { UserService } from '@/services/user-service';
import { formatDate } from '@/utils/date-format';

import { UserCard } from './UserCard';
import { useUserData } from './hooks';

import type { User, UserRole } from '@/types';
```

**Bad:**
```typescript
import { UserCard } from './UserCard';
import { useState, useEffect } from 'react';
import type { User } from '@/types';
import { UserService } from '@/services/user-service';
import { z } from 'zod';
```

#### G4.2 절대 경로 vs 상대 경로 [Warning]

**규칙:** 같은 모듈/기능 내부에서는 상대 경로, 모듈 외부에서는 절대 경로(`@/`)를 사용합니다.

**이유:** 절대 경로는 파일 이동 시 import가 깨지지 않고, 상대 경로는 모듈 내부 응집도를 표현합니다.

**Good:**
```typescript
// 같은 모듈 내부 → 상대 경로
import { validateUser } from './validators';
import { UserCard } from './components/UserCard';

// 다른 모듈 → 절대 경로
import { logger } from '@/lib/logger';
import { ApiClient } from '@/services/api-client';
```

**Bad:**
```typescript
// 같은 모듈인데 절대 경로 사용
import { validateUser } from '@/features/user/validators';
// 다른 모듈인데 상대 경로 사용
import { logger } from '../../../lib/logger';
```

#### G4.3 Barrel Export 주의 [Warning]

**규칙:** Barrel export(`index.ts`)는 패키지 경계에서만 사용합니다. 내부 모듈에서는 직접 import합니다.

**이유:** 과도한 barrel export는 순환 의존성과 번들 크기 증가를 유발합니다.

**Good:**
```typescript
// src/features/user/index.ts (패키지 경계)
export { UserService } from './user-service';
export { UserCard } from './components/UserCard';
export type { User, UserRole } from './types';

// 외부에서 사용
import { UserService, UserCard } from '@/features/user';
```

**Bad:**
```typescript
// 모든 폴더에 index.ts를 만들어 re-export
// src/features/user/components/index.ts
// src/features/user/hooks/index.ts
// src/features/user/utils/index.ts
// → 불필요한 간접 참조, 순환 의존성 위험
```

#### G4.4 순환 의존성 금지 [Error]

**규칙:** 모듈 간 순환 의존성을 만들지 않습니다.

**이유:** 순환 의존성은 예측 불가능한 초기화 순서와 런타임 에러를 유발합니다.

**Good:**
```typescript
// 공통 타입은 별도 모듈로 분리
// types/user.ts
export interface User { id: string; name: string; }

// services/user-service.ts
import type { User } from '@/types/user';

// controllers/user-controller.ts
import type { User } from '@/types/user';
import { UserService } from '@/services/user-service';
```

**Bad:**
```typescript
// A → B → A 순환 참조
// user-service.ts
import { UserController } from './user-controller'; // A → B

// user-controller.ts
import { UserService } from './user-service'; // B → A
```

---

### G5. 에러 처리

#### G5.1 커스텀 에러 클래스 [Warning]

**규칙:** 도메인별 커스텀 에러 클래스를 정의하여 사용합니다. 에러 타입에 따른 분기 처리와 추적이 용이합니다.

**Good:**
```typescript
class AppError extends Error {
  constructor(message: string, public readonly code: string, public readonly statusCode = 500) {
    super(message);
    this.name = this.constructor.name;
  }
}
class NotFoundError extends AppError {
  constructor(resource: string, id: string) { super(`${resource} not found: ${id}`, 'NOT_FOUND', 404); }
}
```

**Bad:** 일반 `Error`만 사용 → catch에서 에러 유형 구분 불가
```typescript
throw new Error('User not found');
```

#### G5.2 try-catch 범위 최소화 [Warning]

**규칙:** try-catch 블록은 실제로 예외가 발생할 수 있는 코드만 감쌉니다. 넓은 범위의 try-catch는 의도하지 않은 에러를 삼키고 디버깅을 어렵게 합니다.

**Good:** 검증은 try 밖, DB 호출만 try 안, 변환도 try 밖
```typescript
const validId = validateUserId(userId);
let user: User;
try { user = await userRepository.findById(validId); }
catch (error) { throw new DatabaseError('Failed to fetch user', { cause: error }); }
return transformUser(user);
```

**Bad:** 전체 로직을 try로 감싸기 → 어떤 단계에서 실패했는지 알 수 없음

#### G5.3 에러 전파 규칙 [Warning]

**규칙:** 에러를 catch한 후 재throw할 때 `{ cause: error }`로 원인 에러를 보존합니다.

**Good:** `throw new NotificationError('Failed', { cause: error });`
**Bad:** `throw new Error('Failed');` (원인 소실) 또는 빈 `catch {}` (에러 무시)

#### G5.4 에러 로깅 [Warning]

**규칙:** 에러 로깅 시 에러 객체 전체를 포함하고, 맥락 정보를 함께 기록합니다.

**이유:** 에러 메시지만으로는 디버깅에 필요한 정보가 부족합니다.

**Good:**
```typescript
try {
  await processPayment(order);
} catch (error) {
  logger.error('Payment processing failed', {
    orderId: order.id,
    userId: order.userId,
    amount: order.total,
    error,
  });
  throw error;
}
```

**Bad:**
```typescript
try {
  await processPayment(order);
} catch (error) {
  console.log('Error occurred'); // 맥락 정보 없음
  throw error;
}
```

#### G5.5 에러 코드 중앙 관리 [Warning]

**규칙:** 에러 코드를 문자열 리터럴로 흩어 쓰지 않고, 중앙 집중형 `as const` 객체로 관리합니다. 중앙 관리하면 에러 코드 검색, 문서화, 클라이언트-서버 계약 유지가 쉬워집니다.

**Good:**
```typescript
const ERROR_CODE = {
  AUTH_TOKEN_EXPIRED: 'AUTH_TOKEN_EXPIRED',
  USER_NOT_FOUND: 'USER_NOT_FOUND',
  VALIDATION_FAILED: 'VALIDATION_FAILED',
} as const;
type ErrorCode = typeof ERROR_CODE[keyof typeof ERROR_CODE];

throw new AppError('User not found', ERROR_CODE.USER_NOT_FOUND, 404);
```

**Bad:** 문자열 리터럴 직접 사용 → 오타, 대소문자 불일치, 목록 파악 불가
```typescript
throw new AppError('Not found', 'NOT_FOUND', 404);
throw new AppError('Not found', 'not_found', 404); // 대소문자 불일치
```

---

## [Verify 모드] 코드 검증 워크플로우

Verify 모드는 지정된 파일/디렉토리의 코드를 G1-G5 핵심 규칙으로 검증하고 보고서를 생성합니다.

> **참고:** G6-G9 검증이 필요하면 확장 스킬을 사용하세요:
> - G6 주석/문서화, G7 테스트, G8 Git/협업 → `code-convention-quality verify`
> - G9 보안 → `code-convention-security verify`

### Step 1: 검증 대상 수집

인수로 전달된 파일 경로 또는 glob 패턴을 사용하여 검증 대상 파일을 수집합니다. 인수가 없으면 프로젝트의 소스 디렉토리 전체를 대상으로 합니다.

Glob 도구를 사용하여 대상 파일을 수집합니다:
- 패턴: `**/*.{ts,tsx,js,jsx}`
- `node_modules/`, `dist/`, `.next/` 디렉토리는 제외

### Step 2: G1 네이밍 검사

각 파일을 읽고 다음을 확인합니다:
- 변수/함수가 camelCase인지
- 상수가 UPPER_SNAKE_CASE인지
- 클래스/인터페이스/타입이 PascalCase인지
- Boolean 변수에 적절한 접두사가 있는지

Grep 도구를 사용하여 snake_case 변수를 탐지합니다 (상수 제외):
- 패턴: `(const|let|var) [a-z][a-z]*_[a-z]`
- Glob 필터: `*.{ts,tsx}`
- 경로: `<target-path>`
- **면제:** 구조 분해 할당(`const { snake_case } = ...`)은 외부 API 응답 매핑일 수 있으므로 면제
- **면제:** `*.d.ts` 타입 선언 파일은 면제
- **면제:** `*.config.ts`, `*.config.js` 설정 파일은 면제 (도구가 요구하는 네이밍)

### Step 3: G2 타입 검사

Grep 도구를 사용하여 `any` 타입 사용을 탐지합니다:
- 패턴 1: `: any\b` (타입 어노테이션)
- 패턴 2: `as any\b` (타입 단언)
- Glob 필터: `*.{ts,tsx}`
- 경로: `<target-path>`
- **면제:** 주석 행(`//`, `*`, `/*`)에 포함된 `any`는 면제
- **면제:** `*.d.ts` 타입 선언 파일은 면제 (서드파티 타입 정의)
- **면제:** `// eslint-disable` 또는 `// @ts-ignore` 주석이 달린 행은 의도적 사용으로 면제 (단, 보고서에 [Info]로 기록)

strict 모드 확인:
- Read 도구로 `tsconfig.json`을 읽어 `"strict": true` 여부 확인

### Step 4: G3 함수 검사

각 파일을 Read 도구로 읽고 다음을 확인합니다:
- 함수 길이가 30줄 이하인지
- 매개변수가 3개 이하인지
- 깊은 중첩(4단계 이상)이 없는지

### Step 5: G4 Import/Export 검사

순환 의존성 탐지 (madge 사용 가능 시):
```bash
npx madge --circular --extensions ts,tsx <target-path> 2>/dev/null
```

Grep 도구를 사용하여 상대 경로의 과도한 깊이를 탐지합니다:
- 패턴: `from '\.\./\.\./\.\.`
- Glob 필터: `*.{ts,tsx}`
- 경로: `<target-path>`

### Step 6: G5 에러 처리 검사

Grep 도구를 사용하여 에러 무시 패턴을 탐지합니다:
- 패턴 1: `catch\s*\{` (에러 변수 없이 catch)
- 패턴 2: `catch\s*\(\s*\)` (빈 catch 파라미터)
- 패턴 3: `catch.*console\.log` (console.log를 에러 핸들링에 사용)
- Glob 필터: `*.{ts,tsx}`
- 경로: `<target-path>`

### Step 7: 보고서 생성

모든 검사 결과를 취합하여 다음 형식으로 보고서를 출력합니다:

```markdown
## 코드 컨벤션 검증 보고서 (Core: G1-G5)
**검증 대상:** <경로> | **검증 일시:** <날짜> | **검증 파일 수:** <N개>

### 요약
| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| G1-G5 각 항목 | N | N | N | ✅/⚠️/❌ |
| **합계** | **N** | **N** | **N** | — |
> 💡 G6-G9 검증 → `code-convention-quality verify` / `code-convention-security verify`

### 상세 위반 목록
| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
상태 기준: ✅ Error 0 & Warning 0 / ⚠️ Error 0 & Warning 1+ / ❌ Error 1+
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **서드파티 타입 호환** — 외부 라이브러리의 타입 정의에 `any`가 포함된 경우 (예: `@types/*` 패키지)
2. **마이그레이션 중인 JS→TS 코드** — 점진적 마이그레이션 과정에서 임시로 `any`를 사용하는 경우 (주석으로 TODO 표시 필요)
3. **프레임워크 컨벤션** — React의 `useState`, Vue의 `ref()` 등 프레임워크가 정한 패턴
4. **코드 생성기 출력** — Prisma, GraphQL Codegen 등 자동 생성된 코드
5. **레거시 코드 수정** — 기존 코드의 스타일을 유지하면서 최소한의 수정만 하는 경우 (새 코드에는 규칙 적용)
6. **설정 파일** — `*.config.ts`, `*.config.js` 등 도구 설정 파일의 특수 구조

## Related Files

| File | Purpose |
|------|---------|
| `tsconfig.json` | TypeScript 컴파일러 설정 (strict 모드 확인) |
| `.eslintrc.*` / `eslint.config.*` | ESLint 설정 (포매팅 규칙 위임) |
| `.prettierrc.*` | Prettier 설정 (포매팅 규칙 위임) |
| `code-convention-quality` | 확장 스킬: G6 주석/문서화, G7 테스트, G8 Git/협업 |
| `code-convention-security` | 확장 스킬: G9 보안 |
| `code-convention-react` | 확장 스킬: React 프레임워크 규칙 |
| `code-convention-vue3` | 확장 스킬: Vue 3 프레임워크 규칙 |
| `code-convention-node` | 확장 스킬: Node.js 프레임워크 규칙 |
