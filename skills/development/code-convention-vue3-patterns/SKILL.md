---
name: code-convention-vue3-patterns
description: Vue 3 패턴 컨벤션 가이드 및 검증. Vue 3 Core(code-convention-vue3) 스킬을 확장하여 디렉티브, Router, 파일 구조, 보안 규칙을 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# Vue 3 패턴 컨벤션

## 기반 스킬

이 스킬은 **Core 코드 컨벤션**(`code-convention/SKILL.md`)과 **Vue 3 Core 컨벤션**(`code-convention-vue3/SKILL.md`)의 확장입니다.

**적용 우선순위:**
1. 이 스킬(Vue 3 패턴 확장)의 규칙을 우선 적용
2. Vue 3 Core 스킬의 규칙을 병행 적용
3. Core 스킬의 규칙을 병행 적용
4. 충돌 시 이 스킬 > Vue 3 Core > Core 순서로 우선

> **Claude에게:** Guide 모드 실행 시, 먼저 `code-convention/SKILL.md`를 읽고 Core 규칙을 숙지한 후, `code-convention-vue3/SKILL.md`를 읽고 Vue 3 Core 규칙을 숙지한 뒤, 이 스킬의 규칙을 추가 적용하세요. Verify 모드에서는 Core 검증, Vue 3 Core 검증, 이 스킬의 검증을 모두 수행합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-vue3-patterns guide` | Vue 3 패턴 규칙 적용하여 코드 작성 |
| Verify | `/code-convention-vue3-patterns verify src/` | Vue 3 패턴 검증 + Vue 3 Core 검증 + Core 검증 병행 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 반응성 손실, 메모리 누수, 런타임 에러 |
| `[Warning]` | 권장 | 성능 저하, 일관성, 유지보수 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

---

## [Guide 모드] Vue 3 패턴 규칙

### G4. 디렉티브

#### G4.1 v-if vs v-show 사용 기준 [Warning]

**규칙:** 토글 빈도가 높은 요소에는 `v-show`를, 조건이 런타임에 거의 변하지 않는 요소에는 `v-if`를 사용합니다. `v-if`와 `v-for`를 같은 요소에 함께 사용하지 않습니다.

**이유:** `v-if`는 DOM을 추가/제거하고, `v-show`는 CSS로 숨깁니다. 용도에 맞게 선택해야 합니다.

**Good:**
```vue
<template>
  <!-- 토글 빈도 높음 → v-show -->
  <div v-show="isDropdownOpen" class="dropdown-menu">
    <DropdownItems />
  </div>

  <!-- 조건이 거의 변하지 않음 → v-if -->
  <AdminPanel v-if="user.role === 'admin'" />

  <!-- v-if와 v-for 분리 -->
  <template v-for="item in items" :key="item.id">
    <ItemCard v-if="item.isVisible" :item="item" />
  </template>
</template>
```

**Bad:**
```vue
<template>
  <!-- v-if와 v-for 같은 요소에 사용 (v-if가 매 항목마다 평가) -->
  <ItemCard
    v-for="item in items"
    v-if="item.isVisible"
    :key="item.id"
    :item="item"
  />

  <!-- 토글 빈도 높은데 v-if 사용 → 불필요한 DOM 재생성 -->
  <Tooltip v-if="showTooltip">{{ tooltipText }}</Tooltip>
</template>
```

#### G4.2 커스텀 디렉티브 규칙 [Info]

**규칙:** 커스텀 디렉티브는 `v` 접두사의 camelCase 네이밍을 사용합니다. DOM 조작이 필요한 경우에만 디렉티브를 사용하고, 로직은 composable로 분리합니다.

**이유:** 디렉티브는 DOM 접근이 필요한 경우에 적합하며, 비즈니스 로직은 composable이 더 적합합니다.

**Good:**
```typescript
// directives/v-click-outside.ts
import type { Directive } from 'vue';

export const vClickOutside: Directive<HTMLElement, () => void> = {
  mounted(el, binding) {
    const handler = (event: MouseEvent) => {
      if (!el.contains(event.target as Node)) {
        binding.value();
      }
    };
    el.__clickOutsideHandler = handler;
    document.addEventListener('click', handler);
  },
  unmounted(el) {
    document.removeEventListener('click', el.__clickOutsideHandler);
  },
};
```

**Bad:**
```typescript
// 비즈니스 로직을 디렉티브에 포함
const vValidate: Directive = {
  mounted(el) {
    // API 호출, 상태 관리 등을 디렉티브에서 수행
    // → composable이 더 적합
  },
};
```

#### G4.3 v-for에 key 사용 [Error]

**규칙:** `v-for`에는 항상 고유한 `:key`를 제공합니다. 배열 인덱스를 key로 사용하지 않습니다.

**이유:** 고유한 key가 없으면 Vue의 가상 DOM 패칭이 올바르게 작동하지 않아 렌더링 버그가 발생합니다.

**Good:**
```vue
<template>
  <ul>
    <li v-for="user in users" :key="user.id">
      {{ user.name }}
    </li>
  </ul>

  <TransitionGroup>
    <div v-for="item in items" :key="item.id">
      {{ item.text }}
    </div>
  </TransitionGroup>
</template>
```

**Bad:**
```vue
<template>
  <!-- key 누락 -->
  <li v-for="user in users">{{ user.name }}</li>

  <!-- 인덱스를 key로 사용 (재정렬 시 버그) -->
  <li v-for="(user, index) in users" :key="index">
    {{ user.name }}
  </li>
</template>
```

---

### G5. Router

#### G5.1 Route 네이밍 [Warning]

**규칙:** 모든 라우트에 `name`을 지정합니다. 네비게이션은 경로 문자열 대신 이름을 사용합니다.

**이유:** 이름 기반 네비게이션은 경로 변경 시 코드 수정을 최소화합니다.

**Good:**
```typescript
// router/index.ts
const routes: RouteRecordRaw[] = [
  {
    path: '/users/:id',
    name: 'user-detail',
    component: () => import('@/pages/UserDetail.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/products',
    name: 'product-list',
    component: () => import('@/pages/ProductList.vue'),
  },
];

// 컴포넌트에서 이름으로 네비게이션
router.push({ name: 'user-detail', params: { id: userId } });
```

**Bad:**
```typescript
// name 없이 경로 문자열 사용
router.push(`/users/${userId}`); // 경로 변경 시 모든 곳 수정 필요

// name 미정의
const routes = [
  { path: '/users/:id', component: UserDetail },
];
```

#### G5.2 Navigation Guard [Warning]

**규칙:** 인증/인가 체크는 전역 navigation guard(`router.beforeEach`)에서 처리합니다. 라우트별 guard는 `beforeEnter`를 사용합니다.

**이유:** 중앙화된 guard는 보안 체크 누락을 방지합니다.

**Good:**
```typescript
router.beforeEach(async (to, from) => {
  const authStore = useAuthStore();

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } };
  }

  if (to.meta.requiredRole && authStore.user?.role !== to.meta.requiredRole) {
    return { name: 'forbidden' };
  }
});

// 라우트별 guard
const routes: RouteRecordRaw[] = [
  {
    path: '/admin',
    name: 'admin',
    component: () => import('@/pages/Admin.vue'),
    beforeEnter: (to) => {
      // 관리자 페이지 전용 로직
    },
    meta: { requiresAuth: true, requiredRole: 'admin' },
  },
];
```

**Bad:**
```typescript
// 각 컴포넌트에서 개별적으로 인증 체크 (누락 위험)
// UserProfile.vue
onMounted(() => {
  if (!authStore.isAuthenticated) {
    router.push('/login');
  }
});
```

#### G5.3 동적 라우트와 Lazy Loading [Info]

**규칙:** 라우트 컴포넌트는 `() => import()`로 지연 로딩합니다. 관련 라우트를 그룹화하여 청크를 관리합니다.

**이유:** 라우트 기반 코드 스플리팅은 초기 번들 크기를 줄입니다.

**Good:**
```typescript
const routes: RouteRecordRaw[] = [
  {
    path: '/dashboard',
    name: 'dashboard',
    component: () => import('@/pages/Dashboard.vue'),
  },
  {
    path: '/settings',
    name: 'settings',
    component: () => import('@/pages/Settings.vue'),
    children: [
      {
        path: 'profile',
        name: 'settings-profile',
        component: () => import('@/pages/settings/Profile.vue'),
      },
      {
        path: 'security',
        name: 'settings-security',
        component: () => import('@/pages/settings/Security.vue'),
      },
    ],
  },
];
```

**Bad:**
```typescript
// 모든 컴포넌트를 동기 import
import Dashboard from '@/pages/Dashboard.vue';
import Settings from '@/pages/Settings.vue';
import Profile from '@/pages/settings/Profile.vue';

const routes = [
  { path: '/dashboard', component: Dashboard },
  { path: '/settings', component: Settings },
];
```

---

### G6. 파일 구조

#### G6.1 Feature 기반 디렉토리 구조 [Warning]

**규칙:** 기능(feature) 단위로 디렉토리를 구성합니다.

**이유:** Feature 기반 구조는 관련 코드의 응집도를 높이고, 기능 추가/삭제가 용이합니다.

**Good:**
```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.vue
│   │   │   └── SignupForm.vue
│   │   ├── composables/
│   │   │   └── use-auth.ts
│   │   ├── stores/
│   │   │   └── use-auth-store.ts
│   │   ├── pages/
│   │   │   └── LoginPage.vue
│   │   ├── types.ts
│   │   └── index.ts
│   └── product/
│       ├── components/
│       ├── composables/
│       └── index.ts
├── shared/
│   ├── components/
│   ├── composables/
│   ├── directives/
│   └── utils/
├── router/
│   └── index.ts
├── stores/
│   └── index.ts (Pinia 초기화)
└── App.vue
```

**Bad:**
```
src/
├── components/    # 모든 컴포넌트가 한 곳에
│   ├── LoginForm.vue
│   ├── ProductCard.vue
│   └── ...
├── composables/   # 모든 composable이 한 곳에
├── stores/        # 모든 store가 한 곳에
└── views/         # 모든 페이지가 한 곳에
```

#### G6.2 컴포넌트 분류 [Warning]

**규칙:** 컴포넌트를 기능별로 분류합니다: `pages/` (라우트 연결), `components/` (재사용), `layouts/` (레이아웃).

**이유:** 명확한 분류는 컴포넌트의 역할을 빠르게 파악할 수 있게 합니다.

**Good:**
```
src/shared/
├── components/
│   ├── ui/              # 기본 UI (BaseButton, BaseInput, BaseModal)
│   ├── layout/           # 레이아웃 (AppHeader, AppSidebar, AppFooter)
│   └── feedback/         # 피드백 (AppToast, AppSpinner, AppAlert)
```

#### G6.3 컴포넌트 네이밍 [Warning]

**규칙:** 컴포넌트 파일명은 PascalCase를 사용합니다. 범용 컴포넌트는 `Base` 또는 `App` 접두사를 사용합니다. 단일 인스턴스 컴포넌트는 `The` 접두사를 사용합니다.

**이유:** Vue 공식 스타일 가이드의 우선순위 B 규칙을 따릅니다.

**Good:**
```
src/components/
├── BaseButton.vue        # 범용 UI 컴포넌트
├── BaseInput.vue
├── AppHeader.vue          # 앱 전용 컴포넌트
├── TheNavigation.vue      # 단일 인스턴스
└── UserProfileCard.vue    # 도메인 컴포넌트
```

**Bad:**
```
src/components/
├── button.vue            # PascalCase 미사용
├── Button.vue            # 접두사 없음 (HTML과 충돌 가능)
├── myHeader.vue          # camelCase
└── user-card.vue         # kebab-case (파일명)
```

### G7. 보안

#### G7.1 v-html 사용 제한 [Error]

**규칙:** `v-html`에 사용자 입력이나 외부 데이터를 직접 바인딩하지 않습니다. 반드시 DOMPurify 등으로 새니타이징한 콘텐츠만 전달합니다.

**이유:** `v-html`은 Vue의 템플릿 이스케이프를 우회하여 XSS 공격에 직접 노출됩니다.

**Good:**
```vue
<script setup lang="ts">
import DOMPurify from 'dompurify';
import { computed } from 'vue';

interface Props {
  rawHtml: string;
}

const props = defineProps<Props>();

const sanitizedHtml = computed(() =>
  DOMPurify.sanitize(props.rawHtml, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href', 'target'],
  }),
);
</script>

<template>
  <!-- 새니타이징된 HTML만 사용 -->
  <div v-html="sanitizedHtml" />

  <!-- 가능하면 v-html 대신 텍스트 바인딩 사용 -->
  <p>{{ userInput }}</p>  <!-- Vue가 자동으로 이스케이프 -->
</template>
```

**Bad:**
```vue
<template>
  <!-- 사용자 입력을 직접 바인딩 — XSS 취약! -->
  <div v-html="userComment" />

  <!-- API 응답을 검증 없이 바인딩 -->
  <article v-html="articleData.body" />
</template>
```

#### G7.2 클라이언트 환경 변수 관리 [Error]

**규칙:** `VITE_` 접두사 환경 변수에 서버 비밀키를 포함하지 않습니다. `import.meta.env`를 통해 접근되는 값에는 공개 키(public key)만 사용합니다.

**이유:** `VITE_` 접두사가 붙은 환경 변수는 빌드 시 클라이언트 번들에 포함되어 브라우저에서 누구나 열람할 수 있습니다.

**Good:**
```typescript
// .env — 클라이언트에 공개 키만 노출
VITE_API_BASE_URL=https://api.example.com
VITE_STRIPE_PUBLIC_KEY=pk_live_xxxxx
VITE_SENTRY_DSN=https://xxxxx@sentry.io/xxxxx

// 서버 전용 (VITE_ 접두사 없음 → 번들에 포함되지 않음)
STRIPE_SECRET_KEY=sk_live_xxxxx
DATABASE_URL=postgresql://...

// 코드에서 사용
const apiUrl = import.meta.env.VITE_API_BASE_URL;
const publicKey = import.meta.env.VITE_STRIPE_PUBLIC_KEY;
```

**Bad:**
```typescript
// 비밀키를 VITE_ 접두사로 노출 — 번들에 포함!
VITE_SECRET_KEY=sk_live_xxxxx
VITE_DB_PASSWORD=super_secret
VITE_JWT_SECRET=my-jwt-secret

// 서버 전용 API를 클라이언트에서 직접 호출
const response = await fetch('https://api.stripe.com/v1/charges', {
  headers: { Authorization: `Bearer ${import.meta.env.VITE_SECRET_KEY}` },
});
```

#### G7.3 인증 상태 관리 보안 [Warning]

**규칙:** 인증 토큰을 `localStorage`에 저장하지 않습니다. `httpOnly` 쿠키를 우선 사용하고, Pinia store에는 메모리 기반으로만 보관합니다. Navigation Guard에서 인증 상태를 반드시 검증합니다.

**이유:** `localStorage`는 XSS 공격에 취약하며, navigation guard 누락은 인증되지 않은 사용자의 접근을 허용합니다.

**Good:**
```typescript
// stores/use-auth-store.ts — 메모리 기반 토큰 관리
export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null);
  const isAuthenticated = computed(() => !!user.value);

  async function login(credentials: Credentials) {
    // httpOnly 쿠키로 인증 (토큰을 직접 다루지 않음)
    await fetch('/api/auth/login', {
      method: 'POST',
      credentials: 'include',
      body: JSON.stringify(credentials),
    });
    user.value = await fetchCurrentUser();
  }

  async function logout() {
    await fetch('/api/auth/logout', { method: 'POST', credentials: 'include' });
    user.value = null;
  }

  return { user, isAuthenticated, login, logout };
});

// router — navigation guard에서 인증 검증
router.beforeEach(async (to) => {
  const authStore = useAuthStore();
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } };
  }
});
```

**Bad:**
```typescript
// localStorage에 토큰 저장 — XSS로 탈취 가능!
const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('auth_token'));

  function login(newToken: string) {
    token.value = newToken;
    localStorage.setItem('auth_token', newToken);
  }

  return { token, login };
});

// navigation guard 없이 컴포넌트에서 개별 체크 (누락 위험)
onMounted(() => {
  if (!authStore.isAuthenticated) router.push('/login');
});
```

---

## [Verify 모드] Vue 3 패턴 검증 워크플로우

### Step 1: 검증 대상 수집

Glob 도구를 사용하여 Vue/TS 파일을 수집합니다:
- 패턴: `**/*.{vue,ts}`
- `node_modules/`, `dist/` 디렉토리는 제외

### Step 2: Core + Vue 3 Core 검증 병행

Core 스킬(`code-convention/SKILL.md`)과 Vue 3 Core 스킬(`code-convention-vue3/SKILL.md`)의 Verify 워크플로우를 먼저 실행합니다.

### Step 3: G4 디렉티브 검사

Grep 도구를 사용하여 탐지합니다:

v-if와 v-for 동시 사용:
- 패턴: `v-for.*v-if|v-if.*v-for`
- Glob 필터: `*.vue`

v-for에서 key 누락:
- 패턴: `v-for=`
- Glob 필터: `*.vue`
- 결과에서 `:key` 포함 행은 면제 처리
- **참고:** `v-for`와 `:key`가 같은 행이 아닌 경우(멀티라인 속성), 컨텍스트(-A 3)를 확인하여 `:key` 존재 여부 판단

인덱스를 key로 사용하는 패턴:
- 패턴: `:key="index|:key="i\b`
- Glob 필터: `*.vue`

### Step 4: G5 Router 검사

Grep 도구를 사용하여 탐지합니다:

라우트 name 누락:
- 패턴: `path:`
- 경로: `<target-path>/router`
- Glob 필터: `*.ts`
- 컨텍스트(-A 3)를 확인하여 `name:` 미포함 시 위반

동기 import 사용:
- 패턴: `import.*from.*(pages|views)`
- 경로: `<target-path>/router`
- Glob 필터: `*.ts`
- `import type` 포함 행은 면제 처리

### Step 5: G7 보안 검사

Grep 도구를 사용하여 탐지합니다:

v-html 사용:
- 패턴: `v-html`
- Glob 필터: `*.vue`
- 해당 파일에 `DOMPurify` 또는 `sanitize` import가 없으면 위반

프론트엔드 환경 변수에 비밀키 포함 여부:
- 패턴: `VITE_.*(SECRET|PASSWORD|PRIVATE)`
- Glob 필터: `*.{env*,ts,vue}`

localStorage에 토큰 저장:
- 패턴: `(localStorage|sessionStorage)\.setItem.*(token|auth)`
- Glob 필터: `*.{ts,vue}`
- 대소문자 무시 옵션 사용

### Step 6: 보고서 생성

Core 검증 결과, Vue 3 Core 검증 결과, Vue 3 패턴 검증 결과를 통합하여 보고서를 출력합니다.

```markdown
## Vue 3 패턴 컨벤션 검증 보고서

**검증 대상:** <경로>
**검증 일시:** <날짜>
**적용 규칙:** Core + Vue 3 Core + Vue 3 Patterns

### 요약

| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| Core: G1-G5 | ... | ... | ... | ... |
| Vue Core: G1-G3 | ... | ... | ... | ... |
| Vue Patterns: G4. 디렉티브 | 1 | 0 | 0 | ❌ |
| Vue Patterns: G5. Router | 0 | 1 | 0 | ⚠️ |
| Vue Patterns: G6. 파일 구조 | 0 | 0 | 1 | ✅ |
| Vue Patterns: G7. 보안 | 0 | 0 | 0 | ✅ |

### 상세 위반 목록

| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
| 1 | Error | G4.3 | src/components/List.vue | 12 | v-for에 key 누락 | `:key="item.id"` 추가 |
| ... | | | | | | |
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **Nuxt 컨벤션** — Nuxt의 auto-import, 파일 기반 라우팅, 디렉토리 구조 규칙
2. **Vuetify/Quasar 패턴** — UI 프레임워크가 요구하는 컴포넌트 사용 패턴
3. **테스트 코드** — 테스트에서의 간소화된 컴포넌트, mount 옵션
4. **레이아웃 파일** — `App.vue`, 레이아웃 컴포넌트의 특수 구조
5. **자동 생성 코드** — Nuxt의 `.nuxt/`, Vue CLI의 자동 설정 파일

## Related Files

| File | Purpose |
|------|---------|
| `code-convention/SKILL.md` | Core 규칙 (기반) |
| `code-convention-vue3/SKILL.md` | Vue 3 Core 규칙 (SFC, Composition API, Pinia) |
| `vite.config.*` | Vite 설정 |
| `tsconfig.json` | TypeScript 설정 |
| `src/router/index.ts` | Vue Router 설정 |
| `src/stores/` | Pinia store 디렉토리 |
