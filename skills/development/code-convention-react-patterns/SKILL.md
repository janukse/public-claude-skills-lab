---
name: code-convention-react-patterns
description: React 패턴 컨벤션 가이드 및 검증. React Core(code-convention-react) 스킬을 확장하여 스타일링, 성능, 파일 구조, 보안 규칙을 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# React 패턴 컨벤션

## 기반 스킬

이 스킬은 **Core 코드 컨벤션**(`code-convention/SKILL.md`)과 **React Core 컨벤션**(`code-convention-react/SKILL.md`)의 확장입니다.

**적용 우선순위:**
1. 이 스킬(React 패턴 확장)의 규칙을 우선 적용
2. React Core 스킬의 규칙을 병행 적용
3. Core 스킬의 규칙을 병행 적용
4. 충돌 시 이 스킬 > React Core > Core 순으로 우선

> **Claude에게:** Guide 모드 실행 시, 먼저 `code-convention/SKILL.md`(Core)와 `code-convention-react/SKILL.md`(React Core)를 읽고 규칙을 숙지한 후 이 스킬의 규칙을 추가 적용하세요. Verify 모드에서는 Core 검증, React Core 검증, 그리고 이 스킬의 검증을 모두 수행합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-react-patterns guide` | React 패턴 규칙 적용하여 코드 작성 |
| Verify | `/code-convention-react-patterns verify src/` | React 패턴 검증 + React Core 검증 + Core 검증 병행 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 버그, 무한 리렌더링, 메모리 누수 |
| `[Warning]` | 권장 | 성능 저하, 일관성, 유지보수 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

---

## [Guide 모드] React 패턴 규칙

### G4. 스타일링

#### G4.1 Tailwind CSS 규칙 [Warning]

**규칙:** Tailwind 사용 시 클래스 정렬은 Prettier 플러그인에 위임합니다. 반복되는 클래스 조합은 `@apply` 또는 컴포넌트로 추출합니다. 조건부 클래스에는 `clsx`/`cn` 유틸리티를 사용합니다.

**이유:** 일관된 클래스 관리는 스타일 유지보수를 쉽게 합니다.

**Good:**
```typescript
import { cn } from '@/lib/utils';

interface ButtonProps {
  variant: 'primary' | 'secondary';
  size: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  children: React.ReactNode;
}

function Button({ variant, size, disabled, children }: ButtonProps) {
  return (
    <button
      className={cn(
        'rounded font-medium transition-colors',
        {
          'bg-blue-600 text-white hover:bg-blue-700': variant === 'primary',
          'bg-gray-200 text-gray-800 hover:bg-gray-300': variant === 'secondary',
          'sm': 'px-2 py-1 text-sm',
          'md': 'px-4 py-2 text-base',
          'lg': 'px-6 py-3 text-lg',
        }[size] || 'px-4 py-2',
        disabled && 'cursor-not-allowed opacity-50',
      )}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

**Bad:**
```typescript
// 인라인 스타일과 Tailwind 혼용
<div style={{ marginTop: '10px' }} className="flex items-center" />

// 조건부 클래스를 문자열 연결로 처리
<div className={'btn ' + (isActive ? 'btn-active' : '') + ' ' + (isLarge ? 'btn-lg' : '')} />
```

#### G4.2 CSS Modules 규칙 [Info]

**규칙:** CSS Modules 사용 시 `.module.css` / `.module.scss` 확장자를 사용합니다. 클래스 이름은 camelCase로 import합니다.

**이유:** CSS Modules는 스코프가 지정된 스타일로 클래스명 충돌을 방지합니다.

**Good:**
```typescript
// UserProfile.module.css
// .container { ... }
// .profileImage { ... }

import styles from './UserProfile.module.css';

function UserProfile() {
  return (
    <div className={styles.container}>
      <img className={styles.profileImage} src={avatar} alt="" />
    </div>
  );
}
```

**Bad:**
```typescript
// 전역 CSS import
import './UserProfile.css';

function UserProfile() {
  return <div className="container">...</div>; // 클래스 충돌 위험
}
```

#### G4.3 styled-components 규칙 [Info]

**규칙:** styled-components 사용 시 스타일 컴포넌트는 파일 하단 또는 별도 `.styles.ts` 파일에 정의합니다. 동적 스타일은 Props를 통해 전달합니다.

**이유:** 스타일과 로직 분리는 코드 가독성을 높입니다.

**Good:**
```typescript
// Button.styles.ts
import styled from 'styled-components';

export const StyledButton = styled.button<{ $variant: 'primary' | 'secondary' }>`
  padding: 8px 16px;
  border-radius: 4px;
  background-color: ${({ $variant }) =>
    $variant === 'primary' ? '#3b82f6' : '#e5e7eb'};
`;

// Button.tsx
import { StyledButton } from './Button.styles';

function Button({ variant, children }: ButtonProps) {
  return <StyledButton $variant={variant}>{children}</StyledButton>;
}
```

**Bad:**
```typescript
// 스타일과 로직이 혼재
function Button({ variant, children }: ButtonProps) {
  const StyledButton = styled.button`...`; // 렌더링마다 재생성!
  return <StyledButton>{children}</StyledButton>;
}
```

#### G4.4 SCSS/Less 규칙 [Info]

**규칙:** SCSS/Less 사용 시 네스팅은 3단계 이하로 제한합니다. 변수는 의미 있는 이름을 사용합니다.

**이유:** 깊은 네스팅은 CSS 선택자 특이성을 높이고, 유지보수를 어렵게 합니다.

**Good:**
```scss
// 3단계 이하 네스팅
.card {
  .card-header {
    .title {
      font-size: 1.5rem;
    }
  }

  .card-body {
    padding: 1rem;
  }
}
```

**Bad:**
```scss
// 과도한 네스팅 (4단계 이상)
.page {
  .content {
    .card {
      .card-header {
        .title {
          .icon { /* 6단계... */ }
        }
      }
    }
  }
}
```

---

### G5. 성능

#### G5.1 React.memo 사용 기준 [Warning]

**규칙:** `React.memo`는 다음 조건을 모두 만족할 때 사용합니다: (1) 부모가 자주 리렌더링됨 (2) Props가 자주 변경되지 않음 (3) 렌더링 비용이 높음. 프로파일러로 확인 후 적용합니다.

**이유:** 불필요한 `React.memo`는 비교 비용만 추가하고 성능 이점이 없습니다.

**Good:**
```typescript
// 렌더링 비용이 높고, props가 자주 변경되지 않는 경우
const ExpensiveChart = memo(function ExpensiveChart({ data }: ChartProps) {
  // 복잡한 차트 렌더링
  return <canvas ref={drawChart(data)} />;
});

// 리스트 아이템 (부모가 자주 리렌더링되는 경우)
const TodoItem = memo(function TodoItem({ todo, onToggle }: TodoItemProps) {
  return (
    <li onClick={() => onToggle(todo.id)}>
      {todo.text}
    </li>
  );
});
```

**Bad:**
```typescript
// 단순한 컴포넌트에 불필요한 memo
const Label = memo(function Label({ text }: { text: string }) {
  return <span>{text}</span>; // 렌더링 비용이 매우 낮음
});

// 모든 컴포넌트에 memo 적용
const App = memo(() => <div>...</div>); // 최상위 컴포넌트에 무의미
```

#### G5.2 useMemo/useCallback 사용 기준 [Warning]

**규칙:** `useMemo`는 계산 비용이 높은 연산에, `useCallback`은 memo된 자식에 전달하는 콜백에 사용합니다. 단순한 값이나 함수에는 사용하지 않습니다.

**이유:** 과도한 메모이제이션은 코드 복잡성을 높이고, 가비지 컬렉션을 방해합니다.

**Good:**
```typescript
function SearchResults({ query, items }: SearchResultsProps) {
  // 비용이 높은 필터링/정렬
  const filteredItems = useMemo(
    () => items
      .filter((item) => item.name.includes(query))
      .sort((a, b) => a.relevance - b.relevance),
    [query, items],
  );

  // memo된 자식에 전달하는 콜백
  const handleSelect = useCallback(
    (id: string) => onSelect(id),
    [onSelect],
  );

  return <ItemList items={filteredItems} onSelect={handleSelect} />;
}
```

**Bad:**
```typescript
// 단순한 값에 불필요한 useMemo
const greeting = useMemo(() => `Hello, ${name}!`, [name]);

// 모든 함수에 useCallback
const handleClick = useCallback(() => {
  setCount((c) => c + 1);
}, []);
```

#### G5.3 불필요한 리렌더링 방지 [Warning]

**규칙:** 렌더링마다 새로운 참조를 생성하는 패턴을 피합니다: 인라인 객체/배열 리터럴을 props로 전달, JSX 내 인라인 함수 정의.

**이유:** 새 참조는 자식 컴포넌트의 불필요한 리렌더링을 유발합니다.

**Good:**
```typescript
// 상수는 컴포넌트 밖에서 정의
const DEFAULT_STYLE = { color: 'red', fontSize: 14 };
const EMPTY_ARRAY: string[] = [];

function Parent() {
  return <Child style={DEFAULT_STYLE} items={EMPTY_ARRAY} />;
}
```

**Bad:**
```typescript
function Parent() {
  // 매 렌더링마다 새 객체/배열 생성
  return <Child style={{ color: 'red' }} items={[]} />;
}
```

#### G5.4 코드 스플리팅 [Info]

**규칙:** 라우트 수준의 컴포넌트와 무거운 라이브러리는 `React.lazy`와 `Suspense`로 지연 로딩합니다.

**이유:** 초기 번들 크기를 줄여 로딩 시간을 단축합니다.

**Good:**
```typescript
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));
const AdminPanel = lazy(() => import('./pages/AdminPanel'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
        <Route path="/admin" element={<AdminPanel />} />
      </Routes>
    </Suspense>
  );
}
```

**Bad:**
```typescript
// 모든 페이지를 동기 import — 초기 번들에 포함
import Dashboard from './pages/Dashboard';
import Settings from './pages/Settings';
import AdminPanel from './pages/AdminPanel';
```

---

### G6. 파일 구조

#### G6.1 Feature 기반 디렉토리 구조 [Warning]

**규칙:** 기능(feature) 단위로 디렉토리를 구성합니다. 기술 유형(components, hooks, utils) 기반의 평면 구조보다 feature 기반을 우선합니다.

**이유:** Feature 기반 구조는 관련 코드의 응집도를 높이고, 기능 추가/삭제가 용이합니다.

**Good:**
```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── SignupForm.tsx
│   │   ├── hooks/
│   │   │   └── use-auth.ts
│   │   ├── api/
│   │   │   └── auth-api.ts
│   │   ├── types.ts
│   │   └── index.ts
│   ├── cart/
│   │   ├── components/
│   │   ├── hooks/
│   │   └── index.ts
│   └── product/
│       ├── components/
│       ├── hooks/
│       └── index.ts
├── shared/
│   ├── components/
│   ├── hooks/
│   └── utils/
└── app/
    ├── routes/
    └── layout/
```

**Bad:**
```
src/
├── components/
│   ├── LoginForm.tsx
│   ├── SignupForm.tsx
│   ├── CartItem.tsx
│   ├── ProductCard.tsx
│   └── ... (수십 개의 컴포넌트)
├── hooks/
│   ├── use-auth.ts
│   ├── use-cart.ts
│   └── ...
└── utils/
    └── ...
```

#### G6.2 공통 컴포넌트 분리 [Warning]

**규칙:** 2개 이상의 feature에서 사용하는 컴포넌트는 `shared/components/`로 이동합니다. UI 라이브러리 래퍼 컴포넌트도 여기에 위치합니다.

**이유:** 공통 컴포넌트의 명확한 위치는 중복 구현을 방지합니다.

**Good:**
```
src/shared/
├── components/
│   ├── ui/              # 기본 UI (Button, Input, Modal, ...)
│   ├── layout/           # 레이아웃 (Header, Footer, Sidebar, ...)
│   └── feedback/         # 피드백 (Toast, Alert, Spinner, ...)
├── hooks/
│   ├── use-debounce.ts
│   └── use-local-storage.ts
└── utils/
    ├── date-format.ts
    └── string-utils.ts
```

#### G6.3 Barrel Export 전략 [Warning]

**규칙:** Feature의 `index.ts`에서는 외부에 공개할 API만 export합니다. 내부 구현 세부사항은 export하지 않습니다.

**이유:** 명확한 public API는 모듈 간 결합도를 낮추고 리팩토링을 용이하게 합니다.

**Good:**
```typescript
// features/auth/index.ts — 공개 API만 export
export { LoginForm } from './components/LoginForm';
export { SignupForm } from './components/SignupForm';
export { useAuth } from './hooks/use-auth';
export type { AuthState, Credentials } from './types';
```

**Bad:**
```typescript
// features/auth/index.ts — 내부 구현까지 export
export { LoginForm } from './components/LoginForm';
export { validatePassword } from './utils/validators'; // 내부 유틸
export { authReducer } from './store/reducer'; // 내부 리듀서
export { AUTH_ACTIONS } from './store/actions'; // 내부 상수
```

### G7. 보안

#### G7.1 dangerouslySetInnerHTML 사용 제한 [Error]

**규칙:** `dangerouslySetInnerHTML`은 반드시 DOMPurify 등으로 새니타이징한 콘텐츠만 전달합니다. 사용자 입력을 직접 삽입하지 않습니다.

**이유:** `dangerouslySetInnerHTML`은 React의 XSS 자동 방어를 우회합니다. 새니타이징 없이 사용하면 스크립트 인젝션에 직접 노출됩니다.

**Good:**
```typescript
import DOMPurify from 'dompurify';

function RichContent({ html }: { html: string }) {
  const sanitized = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href', 'target'],
  });

  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

// 가능하면 dangerouslySetInnerHTML 대신 안전한 대안 사용
function SafeContent({ text }: { text: string }) {
  return <div>{text}</div>; // React가 자동으로 이스케이프
}
```

**Bad:**
```typescript
// 사용자 입력을 직접 삽입 — XSS 취약!
function Comment({ content }: { content: string }) {
  return <div dangerouslySetInnerHTML={{ __html: content }} />;
}

// API 응답을 검증 없이 삽입
function Article({ data }: { data: ArticleData }) {
  return <div dangerouslySetInnerHTML={{ __html: data.body }} />;
}
```

#### G7.2 클라이언트 환경 변수 관리 [Error]

**규칙:** 프론트엔드 환경 변수(`REACT_APP_*`, `NEXT_PUBLIC_*`)에 서버 비밀키를 포함하지 않습니다. 클라이언트에 노출되는 환경 변수에는 공개 키(public key)만 사용합니다.

**이유:** `REACT_APP_`와 `NEXT_PUBLIC_` 접두사가 붙은 환경 변수는 빌드 시 번들에 포함되어 브라우저에서 누구나 열람할 수 있습니다.

**Good:**
```typescript
// .env — 클라이언트에 공개 키만 노출
REACT_APP_STRIPE_PUBLIC_KEY=pk_live_xxxxx
REACT_APP_API_BASE_URL=https://api.example.com

// Next.js
NEXT_PUBLIC_GA_TRACKING_ID=G-XXXXXXXXXX
NEXT_PUBLIC_SENTRY_DSN=https://xxxxx@sentry.io/xxxxx

// 서버 전용 (접두사 없음 → 번들에 포함되지 않음)
STRIPE_SECRET_KEY=sk_live_xxxxx
DATABASE_URL=postgresql://...
JWT_SECRET=your-secret-key
```

**Bad:**
```typescript
// 비밀키를 프론트엔드 환경 변수에 포함 — 번들에 노출!
REACT_APP_SECRET_KEY=sk_live_xxxxx
REACT_APP_DB_PASSWORD=super_secret
NEXT_PUBLIC_JWT_SECRET=my-jwt-secret

// 서버 전용 API를 클라이언트에서 직접 호출
const response = await fetch('https://api.stripe.com/v1/charges', {
  headers: { Authorization: `Bearer ${process.env.REACT_APP_SECRET_KEY}` },
});
```

#### G7.3 인증 상태 관리 보안 [Warning]

**규칙:** 인증 토큰을 `localStorage`에 저장하지 않습니다. `httpOnly` 쿠키를 우선 사용하고, 불가피한 경우 메모리(상태)에 보관합니다. 토큰 갱신 로직을 구현합니다.

**이유:** `localStorage`는 XSS 공격에 취약하여, 악성 스크립트가 저장된 토큰을 탈취할 수 있습니다. `httpOnly` 쿠키는 JavaScript에서 접근할 수 없어 더 안전합니다.

**Good:**
```typescript
// httpOnly 쿠키 방식 — 서버에서 설정
// 서버: res.cookie('token', jwt, { httpOnly: true, secure: true, sameSite: 'strict' })

// 클라이언트: 토큰을 직접 다루지 않음
async function login(credentials: Credentials) {
  await fetch('/api/auth/login', {
    method: 'POST',
    credentials: 'include', // 쿠키 자동 전송
    body: JSON.stringify(credentials),
  });
}

// 불가피하게 토큰을 다뤄야 하는 경우 — 메모리에만 보관
const useAuthStore = create<AuthStore>((set) => ({
  token: null, // 메모리에만 존재, 새로고침 시 재인증
  setToken: (token: string | null) => set({ token }),
}));
```

**Bad:**
```typescript
// localStorage에 토큰 저장 — XSS로 탈취 가능!
function login(credentials: Credentials) {
  const { token } = await authApi.login(credentials);
  localStorage.setItem('auth_token', token);
}

// sessionStorage도 XSS에 동일하게 취약
sessionStorage.setItem('access_token', token);

// 토큰 갱신 로직 없이 만료된 토큰 계속 사용
const token = localStorage.getItem('auth_token');
fetch('/api/data', { headers: { Authorization: `Bearer ${token}` } });
```

---

## [Verify 모드] React 패턴 검증 워크플로우

### Step 1: 검증 대상 수집

Glob 도구를 사용하여 React 파일을 수집합니다:
- 패턴: `**/*.{tsx,jsx}`
- `node_modules/`, `dist/` 디렉토리는 제외

### Step 2: Core + React Core 검증 병행

Core 스킬(`code-convention/SKILL.md`)의 Verify 워크플로우와 React Core 스킬(`code-convention-react/SKILL.md`)의 Verify 워크플로우를 먼저 실행하여 기본 규칙 검증을 수행합니다.

### Step 3: G4 스타일링 검사

Grep 도구를 사용하여 탐지합니다:

인라인 스타일과 Tailwind 혼용:
- 패턴: `style=.*className=|className=.*style=`
- Glob 필터: `*.tsx`

조건부 클래스를 문자열 연결로 처리:
- 패턴: `className=\{.*\+`
- Glob 필터: `*.tsx`

styled-components 컴포넌트 내부 정의:
- 패턴: `styled\.`
- Glob 필터: `*.tsx`
- 컨텍스트(-B 3)를 확인하여 컴포넌트 함수 내부인지 판별

### Step 4: G5 성능 검사

Grep 도구를 사용하여 탐지합니다:

인라인 객체/배열을 props로 전달하는 패턴:
- 패턴: `=\{\{|=\{\[`
- Glob 필터: `*.tsx`
- **면제:** `className`, `style=` 포함 행 (CSS-in-JS 패턴)
- **면제:** `key=` 포함 행 (key prop은 원시값)
- **면제:** `data-testid`, `aria-` 등 테스트/접근성 속성
- **면제:** Storybook story 파일 (`*.stories.tsx`)

styled-components 컴포넌트 내부 정의:
- 패턴: `styled\.`
- Glob 필터: `*.tsx`
- 컨텍스트(-B 3)를 확인하여 컴포넌트 함수 내부인지 판별

### Step 5: G6 파일 구조 검사

프로젝트의 디렉토리 구조를 분석하여 feature 기반 구조를 따르는지 확인합니다.

Glob 도구로 디렉토리 구조를 확인합니다:
- 패턴: `**/*/`

Grep 도구를 사용하여 하나의 파일에서 여러 컴포넌트 export를 탐지합니다:
- 패턴: `^export (function|const) [A-Z]`
- Glob 필터: `*.tsx`
- 동일 파일에서 2회 이상 매칭 시 위반

### Step 6: G7 보안 검사

Grep 도구를 사용하여 탐지합니다:

dangerouslySetInnerHTML 사용:
- 패턴: `dangerouslySetInnerHTML`
- Glob 필터: `*.{tsx,jsx}`
- 해당 파일에 `DOMPurify` 또는 `sanitize` import가 없으면 위반

프론트엔드 환경 변수에 비밀키 포함 여부:
- 패턴: `(REACT_APP_|NEXT_PUBLIC_).*(SECRET|PASSWORD|PRIVATE)`
- Glob 필터: `*.{env*,ts,tsx}`

localStorage에 토큰 저장:
- 패턴: `(localStorage|sessionStorage)\.setItem.*(token|auth)`
- Glob 필터: `*.{ts,tsx}`
- 대소문자 무시 옵션 사용

### Step 7: 보고서 생성

Core 검증, React Core 검증, React 패턴 검증 결과를 통합하여 보고서를 출력합니다.

```markdown
## React 패턴 컨벤션 검증 보고서

**검증 대상:** <경로>
**검증 일시:** <날짜>
**적용 규칙:** Core + React Core + React 패턴

### 요약

| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| Core: G1-G9 | ... | ... | ... | ... |
| React Core: G1-G3 | ... | ... | ... | ... |
| React 패턴: G4. 스타일링 | 0 | 0 | 1 | ✅ |
| React 패턴: G5. 성능 | 0 | 2 | 0 | ⚠️ |
| React 패턴: G6. 파일 구조 | 0 | 0 | 0 | ✅ |
| React 패턴: G7. 보안 | 0 | 0 | 0 | ✅ |

### 상세 위반 목록

| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
| 1 | Warning | G5.3 | src/components/List.tsx | 45 | 인라인 객체를 props로 전달 | 상수로 추출 |
| ... | | | | | | |
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **Storybook stories** — Story 파일의 특수 export 패턴, 인라인 스타일/객체 사용
2. **UI 라이브러리 패턴** — UI 라이브러리(MUI, Ant Design, shadcn/ui 등)가 요구하는 스타일링/구조 패턴
3. **테스트 코드** — 테스트에서의 인라인 스타일, 간소화된 파일 구조

## Related Files

| File | Purpose |
|------|---------|
| `code-convention/SKILL.md` | Core 규칙 (기반) |
| `code-convention-react/SKILL.md` | React Core 규칙 (기반) |
| `.eslintrc.*` / `eslint.config.*` | ESLint 설정 |
| `tailwind.config.*` | Tailwind CSS 설정 |
| `tsconfig.json` | TypeScript 설정 (JSX 관련) |
