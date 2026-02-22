---
name: code-convention-react
description: React 코드 컨벤션 가이드 및 검증. Core(code-convention) 스킬을 확장하여 React 컴포넌트, Hooks, 상태관리 핵심 규칙을 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# React 코드 컨벤션

## 기반 스킬

이 스킬은 **Core 코드 컨벤션**(`code-convention/SKILL.md`)의 확장입니다.

**적용 우선순위:**
1. 이 스킬(React 확장)의 규칙을 우선 적용
2. Core 스킬의 규칙을 병행 적용
3. 충돌 시 이 스킬의 규칙이 우선

> **Claude에게:** Guide 모드 실행 시, 먼저 `code-convention/SKILL.md`를 읽고 Core 규칙을 숙지한 후 이 스킬의 규칙을 추가 적용하세요. Verify 모드에서는 Core 검증과 React 검증을 모두 수행합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-react guide` | React 코드 작성 시 규칙 적용 |
| Verify | `/code-convention-react verify src/` | React 코드 검증 + Core 검증 병행 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 버그, 무한 리렌더링, 메모리 누수 |
| `[Warning]` | 권장 | 성능 저하, 일관성, 유지보수 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

## 확장 스킬

| 스킬 | 설명 |
|------|------|
| `code-convention-react-patterns/SKILL.md` | 스타일링, 성능, 파일 구조, 보안 규칙을 다루는 확장 스킬 |

---

## [Guide 모드] React 코드 작성 규칙

### G1. 컴포넌트

#### G1.1 함수 컴포넌트 선언 방식 [Warning]

**규칙:** 컴포넌트는 `function` 선언을 사용합니다. `React.FC` 타입은 사용하지 않습니다.

**이유:** `React.FC`는 암시적 `children` prop과 제네릭 제한 등 불필요한 복잡성을 추가합니다.

**Good:**
```typescript
interface UserProfileProps {
  userId: string;
  showAvatar?: boolean;
}

function UserProfile({ userId, showAvatar = true }: UserProfileProps) {
  return (
    <div>
      {showAvatar && <Avatar userId={userId} />}
      <UserInfo userId={userId} />
    </div>
  );
}

export default UserProfile;
```

**Bad:**
```typescript
// React.FC 사용
const UserProfile: React.FC<UserProfileProps> = ({ userId, showAvatar }) => {
  return <div>...</div>;
};

// arrow function으로 컴포넌트 선언
export const UserProfile = ({ userId }: UserProfileProps) => {
  return <div>...</div>;
};
```

#### G1.2 Props 타입 정의 [Error]

**규칙:** 컴포넌트의 Props는 `interface`로 정의하며, `컴포넌트명 + Props` 네이밍을 사용합니다. Props는 `Readonly`이며 직접 수정하지 않습니다.

**이유:** 명확한 Props 타입은 컴포넌트의 API를 문서화하고, 실수를 방지합니다.

**Good:**
```typescript
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  onClick: () => void;
  children: React.ReactNode;
}

function Button({ variant, size = 'md', disabled = false, onClick, children }: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant} btn-${size}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

**Bad:**
```typescript
// Props를 인라인으로 정의
function Button({ variant, onClick }: { variant: string; onClick: any }) {
  return <button onClick={onClick}>{variant}</button>;
}

// Props 타입 없이 사용
function Button(props) {
  return <button onClick={props.onClick}>{props.children}</button>;
}
```

#### G1.3 컴포넌트 파일 구조 [Warning]

**규칙:** 하나의 파일에는 하나의 export 컴포넌트를 정의합니다. 파일 내부의 서브 컴포넌트는 export하지 않습니다.

**이유:** 단일 컴포넌트 파일은 코드 탐색, 테스트, 재사용을 용이하게 합니다.

**Good:**
```typescript
// UserProfile.tsx
interface UserProfileProps { /* ... */ }

// 내부 전용 서브 컴포넌트 (export하지 않음)
function ProfileHeader({ name, avatar }: { name: string; avatar: string }) {
  return <div className="profile-header">...</div>;
}

// 메인 컴포넌트 (export)
function UserProfile({ userId }: UserProfileProps) {
  return (
    <div>
      <ProfileHeader name={user.name} avatar={user.avatar} />
      <ProfileBody user={user} />
    </div>
  );
}

export default UserProfile;
```

**Bad:**
```typescript
// 하나의 파일에서 여러 컴포넌트를 export
export function UserProfile() { /* ... */ }
export function UserAvatar() { /* ... */ }
export function UserBio() { /* ... */ }
```

#### G1.4 컴포넌트 분리 기준 [Info]

**규칙:** 다음 기준 중 하나 이상에 해당하면 컴포넌트를 분리합니다:
- JSX가 50줄을 초과
- 독립적인 상태(state)를 가짐
- 3곳 이상에서 재사용
- 독립적으로 테스트해야 함

**이유:** 적절한 분리는 재사용성과 테스트 용이성을 높입니다.

**Good:**
```typescript
// 분리된 컴포넌트
function OrderSummary({ items, total }: OrderSummaryProps) {
  return (
    <div className="order-summary">
      <ItemList items={items} />
      <PriceBreakdown total={total} />
      <CheckoutButton />
    </div>
  );
}
```

**Bad:**
```typescript
// 하나의 거대한 컴포넌트 (200줄 이상)
function OrderPage() {
  // 상태 10개, 이벤트 핸들러 8개, JSX 100줄...
  return (
    <div>
      {/* 주문 목록, 가격 계산, 결제, 배송 정보를 모두 한 컴포넌트에... */}
    </div>
  );
}
```

---

### G2. Hooks

#### G2.1 커스텀 Hook 네이밍 [Error]

**규칙:** 커스텀 Hook은 `use` 접두사를 사용합니다. Hook의 이름은 반환하는 데이터나 수행하는 동작을 설명합니다.

**이유:** `use` 접두사는 React가 Hook 규칙을 적용하는 데 사용됩니다.

**Good:**
```typescript
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchUser(userId).then(setUser).finally(() => setIsLoading(false));
  }, [userId]);

  return { user, isLoading };
}

function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);
  // ...
  return debouncedValue;
}
```

**Bad:**
```typescript
// use 접두사 없음
function getUser(userId: string) {
  const [user, setUser] = useState(null); // Hook 규칙 위반
  // ...
}

// 이름이 모호
function useData() { /* 어떤 데이터? */ }
function useStuff() { /* 무엇을 하는지 불명확 */ }
```

#### G2.2 의존성 배열 정확성 [Error]

**규칙:** `useEffect`, `useMemo`, `useCallback`의 의존성 배열에 사용하는 모든 외부 값을 포함합니다. ESLint `react-hooks/exhaustive-deps` 규칙을 활성화합니다.

**이유:** 누락된 의존성은 stale closure로 인한 버그를 유발합니다.

**Good:**
```typescript
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    let cancelled = false;
    fetchUser(userId).then((data) => {
      if (!cancelled) setUser(data);
    });
    return () => { cancelled = true; };
  }, [userId]); // userId가 변경되면 재실행

  const fullName = useMemo(
    () => user ? `${user.firstName} ${user.lastName}` : '',
    [user], // user가 변경되면 재계산
  );

  return <div>{fullName}</div>;
}
```

**Bad:**
```typescript
useEffect(() => {
  fetchUser(userId).then(setUser);
}, []); // userId가 빠져있음 — stale closure

useCallback(() => {
  onSubmit(formData);
}, []); // formData, onSubmit이 빠져있음
```

#### G2.3 Effect Cleanup [Error]

**규칙:** `useEffect`에서 구독, 타이머, 비동기 작업은 반드시 cleanup 함수에서 정리합니다.

**이유:** Cleanup이 없으면 메모리 누수와 컴포넌트 언마운트 후 상태 업데이트 에러가 발생합니다.

**Good:**
```typescript
useEffect(() => {
  const controller = new AbortController();

  fetch(`/api/users/${userId}`, { signal: controller.signal })
    .then((res) => res.json())
    .then(setUser)
    .catch((err) => {
      if (err.name !== 'AbortError') setError(err);
    });

  return () => controller.abort();
}, [userId]);

useEffect(() => {
  const timer = setInterval(pollData, 5000);
  return () => clearInterval(timer);
}, [pollData]);
```

**Bad:**
```typescript
useEffect(() => {
  // cleanup 없음 — 컴포넌트 언마운트 후에도 상태 업데이트 시도
  fetch(`/api/users/${userId}`)
    .then((res) => res.json())
    .then(setUser);
}, [userId]);

useEffect(() => {
  setInterval(pollData, 5000); // cleanup 없음 — 메모리 누수
}, []);
```

#### G2.4 Hook 호출 순서 [Error]

**규칙:** Hook은 컴포넌트/Hook 최상위에서만 호출합니다. 조건문, 반복문, 중첩 함수 안에서 호출하지 않습니다.

**이유:** React는 Hook 호출 순서로 상태를 추적하므로, 순서가 변경되면 버그가 발생합니다.

**Good:**
```typescript
function UserDashboard({ userId }: { userId: string }) {
  // Hook은 항상 최상위에서 호출
  const { user, isLoading } = useUser(userId);
  const [tab, setTab] = useState('profile');
  const theme = useTheme();

  if (isLoading) return <Spinner />;
  if (!user) return <NotFound />;

  return <Dashboard user={user} tab={tab} onTabChange={setTab} />;
}
```

**Bad:**
```typescript
function UserDashboard({ userId }: { userId: string }) {
  const { user, isLoading } = useUser(userId);

  if (isLoading) return <Spinner />;

  // 조건부 Hook 호출 — 규칙 위반!
  const [tab, setTab] = useState('profile');
  const theme = useTheme();

  return <Dashboard user={user} tab={tab} />;
}
```

---

### G3. 상태 관리

#### G3.1 서버 상태 관리 (TanStack Query) [Warning]

**규칙:** 서버 데이터 페칭/캐싱에는 TanStack Query(React Query)를 사용합니다. `useEffect` + `useState`로 직접 구현하지 않습니다.

**이유:** TanStack Query는 캐싱, 재검증, 에러 처리, 로딩 상태를 체계적으로 관리합니다.

**Good:**
```typescript
function useUsers(page: number) {
  return useQuery({
    queryKey: ['users', page],
    queryFn: () => fetchUsers(page),
    staleTime: 5 * 60 * 1000, // 5분
  });
}

function usCreateUser() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

**Bad:**
```typescript
// useEffect로 직접 구현 — 캐싱, 에러 처리, 로딩 상태 직접 관리 필요
function useUsers(page: number) {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setLoading(true);
    fetchUsers(page)
      .then(setUsers)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [page]);

  return { users, loading, error };
}
```

#### G3.2 클라이언트 전역 상태 (Zustand) [Info]

**규칙:** 클라이언트 전역 상태 관리에는 Zustand를 권장합니다. 상태는 최소한으로 유지하고, 파생 상태는 `selector`로 계산합니다.

**이유:** Zustand는 보일러플레이트가 적고 TypeScript 지원이 우수합니다.

**Good:**
```typescript
interface AuthStore {
  user: User | null;
  isAuthenticated: boolean;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
}

const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  isAuthenticated: false,
  login: async (credentials) => {
    const user = await authApi.login(credentials);
    set({ user, isAuthenticated: true });
  },
  logout: () => set({ user: null, isAuthenticated: false }),
}));

// 컴포넌트에서 필요한 상태만 구독
function UserMenu() {
  const user = useAuthStore((state) => state.user);
  const logout = useAuthStore((state) => state.logout);
  // ...
}
```

**Bad:**
```typescript
// 하나의 거대한 store에 모든 상태를 담음
const useStore = create((set) => ({
  user: null,
  cart: [],
  theme: 'light',
  notifications: [],
  // ... 20개 이상의 상태
}));
```

#### G3.3 서버/클라이언트 상태 분리 [Warning]

**규칙:** 서버 상태(API 데이터)와 클라이언트 상태(UI 상태)를 혼합하지 않습니다.

**이유:** 서버 상태는 캐싱/재검증이 필요하고, 클라이언트 상태는 즉각적 업데이트가 필요합니다.

**Good:**
```typescript
function ProductPage({ productId }: { productId: string }) {
  // 서버 상태 → TanStack Query
  const { data: product } = useQuery({
    queryKey: ['product', productId],
    queryFn: () => fetchProduct(productId),
  });

  // 클라이언트 상태 → useState/Zustand
  const [selectedSize, setSelectedSize] = useState<string>('');
  const [quantity, setQuantity] = useState(1);

  return <ProductView product={product} size={selectedSize} quantity={quantity} />;
}
```

**Bad:**
```typescript
// Zustand에 서버 데이터를 저장 — 캐싱/재검증 누락
const useProductStore = create((set) => ({
  product: null,
  selectedSize: '',
  quantity: 1,
  fetchProduct: async (id) => {
    const product = await api.get(`/products/${id}`);
    set({ product });
  },
}));
```

---

## [Verify 모드] React 코드 검증 워크플로우

### Step 1: 검증 대상 수집

Glob 도구를 사용하여 React 파일을 수집합니다:
- 패턴: `**/*.{tsx,jsx}`
- `node_modules/`, `dist/` 디렉토리는 제외

### Step 2: Core 검증 병행

Core 스킬(`code-convention/SKILL.md`)의 Verify 워크플로우를 먼저 실행하여 기본 규칙 검증을 수행합니다.

### Step 3: G1 컴포넌트 검사

Grep 도구를 사용하여 탐지합니다:

React.FC 사용:
- 패턴: `React\.FC|React\.FunctionComponent`
- Glob 필터: `*.tsx`

Props 타입 미정의 (function 파라미터에 타입 없음):
- 패턴: `function [A-Z][a-zA-Z]*\(`
- Glob 필터: `*.tsx`
- 결과에서 `Props` 또는 `{.*:.*}` 포함 행은 면제 처리

### Step 4: G2 Hooks 검사

Grep 도구를 사용하여 탐지합니다:

빈 의존성 배열 주의:
- 패턴: `useEffect.*\[\]`
- Glob 필터: `*.tsx`
- **참고:** 빈 배열 자체가 위반은 아님. 컨텍스트(-A 5)를 확인하여 외부 변수(props, state)를 참조하는데 의존성 배열에서 누락된 경우만 위반
- **면제:** 마운트 시 1회 실행이 명확한 경우 (이벤트 리스너 등록 + cleanup 패턴)

cleanup 없는 useEffect (subscribe, addEventListener, setInterval 패턴):
- 패턴: `useEffect`
- Glob 필터: `*.tsx`
- 컨텍스트(-A 10)를 포함하여 읽고, subscribe/addEventListener/setInterval/setTimeout 사용 시 return(cleanup) 존재 여부 확인
- **면제:** 단순 상태 설정만 하는 useEffect (cleanup이 불필요한 경우)

### Step 5: G3 상태 관리 검사

Grep 도구를 사용하여 useEffect 내 데이터 페칭 패턴을 탐지합니다:
- 패턴: `useEffect`
- Glob 필터: `*.tsx`
- 컨텍스트(-A 5)를 포함하여 읽고, `fetch|axios|api\.` 사용 여부 확인

### Step 6: 보고서 생성

Core 검증 결과와 React Core 검증 결과를 통합하여 보고서를 출력합니다.

```markdown
## React 코드 컨벤션 검증 보고서

**검증 대상:** <경로>
**검증 일시:** <날짜>
**적용 규칙:** Core + React Core

### 요약

| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| Core: G1-G9 | ... | ... | ... | ... |
| React Core: G1. 컴포넌트 | 0 | 1 | 0 | ⚠️ |
| React Core: G2. Hooks | 1 | 0 | 0 | ❌ |
| React Core: G3. 상태 관리 | 0 | 1 | 0 | ⚠️ |

### 상세 위반 목록

| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
| 1 | Error | G2.3 | src/components/Chat.tsx | 23 | useEffect cleanup 누락 | WebSocket 구독 해제 추가 |
| ... | | | | | | |
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **서드파티 컴포넌트 패턴** — UI 라이브러리(MUI, Ant Design 등)가 요구하는 패턴
2. **React Server Components** — RSC에서는 Hook 사용 불가, `'use client'` 지시어 필요
3. **Next.js/Remix 컨벤션** — 메타 프레임워크가 정한 파일명/구조 규칙 (예: `page.tsx`, `layout.tsx`)
4. **테스트 코드** — 테스트에서의 인라인 컴포넌트, 간소화된 Props
5. **레거시 class 컴포넌트** — 점진적 마이그레이션 중인 코드

## Related Files

| File | Purpose |
|------|---------|
| `code-convention/SKILL.md` | Core 규칙 (이 스킬의 기반) |
| `code-convention-react-patterns/SKILL.md` | React 패턴 확장 (스타일링, 성능, 파일 구조, 보안) |
| `.eslintrc.*` / `eslint.config.*` | ESLint 설정 (react-hooks 플러그인 확인) |
| `tsconfig.json` | TypeScript 설정 (JSX 관련) |
