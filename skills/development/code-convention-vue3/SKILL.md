---
name: code-convention-vue3
description: Vue 3 코드 컨벤션 가이드 및 검증. Core(code-convention) 스킬을 확장하여 SFC, Composition API, Pinia 핵심 규칙을 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# Vue 3 코드 컨벤션

## 기반 스킬

이 스킬은 **Core 코드 컨벤션**(`code-convention/SKILL.md`)의 확장입니다.

**적용 우선순위:**
1. 이 스킬(Vue 3 확장)의 규칙을 우선 적용
2. Core 스킬의 규칙을 병행 적용
3. 충돌 시 이 스킬의 규칙이 우선

> **Claude에게:** Guide 모드 실행 시, 먼저 `code-convention/SKILL.md`를 읽고 Core 규칙을 숙지한 후 이 스킬의 규칙을 추가 적용하세요. Verify 모드에서는 Core 검증과 Vue 3 검증을 모두 수행합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-vue3 guide` | Vue 3 코드 작성 시 규칙 적용 |
| Verify | `/code-convention-vue3 verify src/` | Vue 3 코드 검증 + Core 검증 병행 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 반응성 손실, 메모리 누수, 런타임 에러 |
| `[Warning]` | 권장 | 성능 저하, 일관성, 유지보수 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

## 확장 스킬

이 스킬은 핵심 Vue 3 규칙(SFC, Composition API, Pinia)을 다룹니다. 추가 패턴 규칙은 확장 스킬을 참조하세요:

| 확장 스킬 | 설명 |
|-----------|------|
| `code-convention-vue3-patterns/SKILL.md` | 디렉티브, Router, 파일 구조, 보안 규칙 |

---

## [Guide 모드] Vue 3 코드 작성 규칙

### G1. SFC (Single File Component)

#### G1.1 script setup 사용 [Warning]

**규칙:** `<script setup lang="ts">`를 사용합니다. Options API와 일반 `<script>` 대신 `<script setup>`을 우선합니다.

**이유:** `<script setup>`은 보일러플레이트를 줄이고, TypeScript 추론이 더 정확합니다.

**Good:**
```vue
<script setup lang="ts">
import { ref, computed } from 'vue';
import UserAvatar from './UserAvatar.vue';

interface Props {
  userId: string;
  showBio?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  showBio: true,
});

const isExpanded = ref(false);
const displayName = computed(() => `User #${props.userId}`);
</script>

<template>
  <div class="user-profile">
    <UserAvatar :user-id="props.userId" />
    <span>{{ displayName }}</span>
  </div>
</template>
```

**Bad:**
```vue
<!-- Options API 사용 -->
<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
  props: {
    userId: { type: String, required: true },
  },
  data() {
    return { isExpanded: false };
  },
  computed: {
    displayName() { return `User #${this.userId}`; },
  },
});
</script>
```

#### G1.2 SFC 블록 순서 [Warning]

**규칙:** SFC 블록 순서는 `<script setup>` → `<template>` → `<style>` 순서를 따릅니다.

**이유:** 일관된 블록 순서는 컴포넌트 구조를 빠르게 파악할 수 있게 합니다.

**Good:**
```vue
<script setup lang="ts">
// 로직
</script>

<template>
  <!-- 마크업 -->
</template>

<style scoped>
/* 스타일 */
</style>
```

**Bad:**
```vue
<template>
  <!-- template이 먼저 오면 로직 파악이 어려움 -->
</template>

<script setup lang="ts">
// 로직
</script>

<style>
/* scoped 누락 -->
</style>
```

#### G1.3 Props 타입 정의 [Error]

**규칙:** `defineProps<T>()`에 TypeScript 인터페이스를 사용합니다. 기본값은 `withDefaults`로 정의합니다.

**이유:** 타입 기반 Props 정의는 런타임 검증보다 안전하고 IDE 지원이 우수합니다.

**Good:**
```vue
<script setup lang="ts">
interface Props {
  title: string;
  count: number;
  items?: string[];
  variant?: 'primary' | 'secondary';
}

const props = withDefaults(defineProps<Props>(), {
  items: () => [],
  variant: 'primary',
});
</script>
```

**Bad:**
```vue
<script setup lang="ts">
// 런타임 props 정의 (TypeScript 이점 누락)
const props = defineProps({
  title: { type: String, required: true },
  count: { type: Number, required: true },
  items: { type: Array, default: () => [] },
});
</script>
```

#### G1.4 Emits 타입 정의 [Warning]

**규칙:** `defineEmits<T>()`에 TypeScript 타입을 사용하여 이벤트와 페이로드 타입을 명시합니다.

**이유:** 타입이 지정된 emit은 부모-자식 통신의 타입 안전성을 보장합니다.

**Good:**
```vue
<script setup lang="ts">
interface Emits {
  (e: 'update', value: string): void;
  (e: 'delete', id: string): void;
  (e: 'submit', data: FormData): void;
}

const emit = defineEmits<Emits>();

function handleUpdate(value: string) {
  emit('update', value);
}
</script>
```

**Bad:**
```vue
<script setup lang="ts">
// 타입 없이 문자열 배열만 사용
const emit = defineEmits(['update', 'delete', 'submit']);

// 페이로드 타입 검증 불가
emit('update', 123); // 런타임에서야 발견
</script>
```

---

### G2. Composition API

#### G2.1 Composable 네이밍 [Error]

**규칙:** Composable 함수는 `use` 접두사를 사용합니다. 파일명도 `use-*.ts` 형식을 따릅니다.

**이유:** `use` 접두사는 Vue 생태계에서 composable임을 명확히 나타냅니다.

**Good:**
```typescript
// composables/use-user.ts
import { ref, onMounted } from 'vue';

export function useUser(userId: string) {
  const user = ref<User | null>(null);
  const isLoading = ref(true);
  const error = ref<Error | null>(null);

  async function fetchUser() {
    try {
      isLoading.value = true;
      user.value = await userApi.getById(userId);
    } catch (e) {
      error.value = e as Error;
    } finally {
      isLoading.value = false;
    }
  }

  onMounted(fetchUser);

  return { user, isLoading, error, refetch: fetchUser };
}
```

**Bad:**
```typescript
// use 접두사 없음
export function getUser(userId: string) {
  const user = ref(null); // composable인데 이름이 일반 함수 같음
  // ...
}

// 파일명 불일치
// composables/userData.ts (use- 접두사 누락)
```

#### G2.2 ref vs reactive 사용 기준 [Warning]

**규칙:** 원시 타입과 교체 가능한 값에는 `ref`를, 중첩 객체에서 구조 분해가 필요 없는 경우에만 `reactive`를 사용합니다. `ref`를 기본으로 사용합니다.

**이유:** `ref`는 일관적이며, `reactive`는 구조 분해 시 반응성을 잃을 수 있습니다.

**Good:**
```typescript
// ref를 기본으로 사용
const count = ref(0);
const user = ref<User | null>(null);
const items = ref<Item[]>([]);

// reactive는 폼 상태 등 중첩 객체에 제한적 사용
const form = reactive({
  name: '',
  email: '',
  address: {
    city: '',
    zipCode: '',
  },
});
```

**Bad:**
```typescript
// reactive로 원시 타입 감싸기 (불필요한 복잡성)
const state = reactive({ count: 0 }); // ref(0)이 더 간단

// reactive 구조 분해 → 반응성 손실
const { name, email } = reactive({ name: '', email: '' });
// name, email은 더 이상 반응적이지 않음!
```

#### G2.3 computed 활용 [Warning]

**규칙:** 파생 상태는 항상 `computed`로 정의합니다. `watch`에서 별도 `ref`를 업데이트하여 파생 상태를 만들지 않습니다.

**이유:** `computed`는 자동 의존성 추적, 캐싱, 최적화를 제공합니다.

**Good:**
```typescript
const firstName = ref('John');
const lastName = ref('Doe');

// 파생 상태 → computed
const fullName = computed(() => `${firstName.value} ${lastName.value}`);

const items = ref<Item[]>([]);
const activeItems = computed(() => items.value.filter((item) => item.isActive));
const totalPrice = computed(() =>
  activeItems.value.reduce((sum, item) => sum + item.price, 0),
);
```

**Bad:**
```typescript
const firstName = ref('John');
const lastName = ref('Doe');
const fullName = ref('');

// watch로 파생 상태 구현 (computed가 더 적합)
watch([firstName, lastName], () => {
  fullName.value = `${firstName.value} ${lastName.value}`;
}, { immediate: true });
```

#### G2.4 watch/watchEffect 사용 기준 [Warning]

**규칙:** `watch`는 특정 소스의 변경에 반응할 때, `watchEffect`는 내부에서 사용하는 모든 반응형 값에 자동 반응할 때 사용합니다. cleanup이 필요한 경우 `onCleanup`을 호출합니다.

**이유:** 적절한 watcher 선택은 의도를 명확히 하고 불필요한 실행을 방지합니다.

**Good:**
```typescript
// 특정 값 변경에 반응 → watch
watch(userId, async (newId, oldId) => {
  if (newId !== oldId) {
    user.value = await fetchUser(newId);
  }
});

// 여러 반응형 값에 자동 반응 → watchEffect
watchEffect((onCleanup) => {
  const controller = new AbortController();

  fetch(`/api/users/${userId.value}`, { signal: controller.signal })
    .then((res) => res.json())
    .then((data) => { user.value = data; });

  onCleanup(() => controller.abort());
});
```

**Bad:**
```typescript
// 즉시 실행이 필요한데 watch + immediate 사용 (watchEffect가 더 간결)
watch(userId, async (id) => {
  user.value = await fetchUser(id);
}, { immediate: true });

// cleanup 누락
watchEffect(() => {
  const timer = setInterval(() => pollData(), 5000);
  // timer 정리 없음 → 메모리 누수
});
```

---

### G3. Pinia 상태 관리

#### G3.1 Store 구조 (Setup Store) [Warning]

**규칙:** Pinia store는 Setup Store 패턴(`defineStore` + 함수)을 사용합니다. Options Store보다 Composition API 스타일을 우선합니다.

**이유:** Setup Store는 `ref`, `computed`, `function`을 직접 사용하여 composable과 일관됩니다.

**Good:**
```typescript
// stores/use-auth-store.ts
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useAuthStore = defineStore('auth', () => {
  // state
  const user = ref<User | null>(null);
  const token = ref<string | null>(null);

  // getters
  const isAuthenticated = computed(() => !!token.value);
  const userName = computed(() => user.value?.name ?? 'Guest');

  // actions
  async function login(credentials: Credentials) {
    const response = await authApi.login(credentials);
    user.value = response.user;
    token.value = response.token;
  }

  function logout() {
    user.value = null;
    token.value = null;
  }

  return { user, token, isAuthenticated, userName, login, logout };
});
```

**Bad:**
```typescript
// Options Store (Composition API와 스타일 불일치)
export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    token: null as string | null,
  }),
  getters: {
    isAuthenticated: (state) => !!state.token,
  },
  actions: {
    async login(credentials: Credentials) {
      // this 사용 필요
    },
  },
});
```

#### G3.2 Store 분리 기준 [Warning]

**규칙:** 도메인별로 store를 분리합니다. 하나의 store가 상태 10개 이상이면 분리를 검토합니다.

**이유:** 작은 store는 테스트, 디버깅, 코드 스플리팅에 유리합니다.

**Good:**
```typescript
// stores/use-auth-store.ts — 인증 관련만
export const useAuthStore = defineStore('auth', () => { /* ... */ });

// stores/use-cart-store.ts — 장바구니 관련만
export const useCartStore = defineStore('cart', () => { /* ... */ });

// stores/use-ui-store.ts — UI 상태만
export const useUiStore = defineStore('ui', () => { /* ... */ });
```

**Bad:**
```typescript
// 모든 상태를 하나의 store에 담음
export const useStore = defineStore('main', () => {
  const user = ref(null);
  const cart = ref([]);
  const theme = ref('light');
  const notifications = ref([]);
  const modals = ref({});
  // ... 20개 이상의 상태
});
```

#### G3.3 Store 네이밍 [Warning]

**규칙:** Store 이름은 `use[도메인]Store` 형식을 사용합니다. 파일명은 `use-[도메인]-store.ts`를 따릅니다. Store ID는 도메인명과 일치합니다.

**이유:** 일관된 네이밍은 store를 빠르게 찾고 구분할 수 있게 합니다.

**Good:**
```typescript
// stores/use-auth-store.ts
export const useAuthStore = defineStore('auth', () => { /* ... */ });

// stores/use-product-store.ts
export const useProductStore = defineStore('product', () => { /* ... */ });
```

**Bad:**
```typescript
// 네이밍 불일치
export const authStore = defineStore('authentication', () => { /* ... */ });
// → 변수명에 use 접두사 누락, ID와 변수명 불일치
```

#### G3.4 Store 간 의존성 [Warning]

**규칙:** Store 간 의존성이 필요한 경우 action 내부에서 다른 store를 호출합니다. 순환 의존성을 만들지 않습니다.

**이유:** 명시적 의존성은 데이터 흐름을 추적 가능하게 합니다.

**Good:**
```typescript
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([]);

  async function checkout() {
    const authStore = useAuthStore(); // action 내부에서 호출
    if (!authStore.isAuthenticated) {
      throw new Error('Login required');
    }
    await cartApi.checkout(items.value, authStore.token);
  }

  return { items, checkout };
});
```

**Bad:**
```typescript
// store 최상위에서 다른 store 호출 (초기화 순서 이슈)
export const useCartStore = defineStore('cart', () => {
  const authStore = useAuthStore(); // 초기화 시점에 호출 — 순서 문제 가능

  // auth → cart → auth 순환 의존성
  const items = ref([]);
  return { items };
});
```

---

## [Verify 모드] Vue 3 코드 검증 워크플로우

### Step 1: 검증 대상 수집

Glob 도구를 사용하여 Vue/TS 파일을 수집합니다:
- 패턴: `**/*.{vue,ts}`
- `node_modules/`, `dist/` 디렉토리는 제외

### Step 2: Core 검증 병행

Core 스킬(`code-convention/SKILL.md`)의 Verify 워크플로우를 먼저 실행합니다.

### Step 3: G1 SFC 검사

Grep 도구를 사용하여 탐지합니다:

Options API 사용:
- 패턴: `defineComponent|export default \{`
- Glob 필터: `*.vue`

script setup 미사용:
- 패턴: `<script `
- Glob 필터: `*.vue`
- 결과에서 `setup` 포함 행은 면제 처리

블록 순서 확인 (template이 script 앞에 오는 경우):
- 패턴: `^<template>`
- Glob 필터: `*.vue`

### Step 4: G2 Composition API 검사

Grep 도구를 사용하여 탐지합니다:

reactive 구조 분해:
- 패턴: `(const|let) \{.*\} = reactive`
- Glob 필터: `*.{vue,ts}`

watch + immediate 대신 watchEffect 사용 가능한 패턴:
- 패턴: `immediate: true`
- Glob 필터: `*.{vue,ts}`
- **참고:** 이 패턴은 [Info] 수준으로 보고. `watch`에서 이전 값(`oldValue`)을 참조하는 경우는 `watchEffect`로 대체 불가하므로 면제

### Step 5: G3 Pinia 검사

Grep 도구를 사용하여 탐지합니다:

Options Store 사용:
- 패턴: `defineStore.*state:`
- Glob 필터: `*.ts`

Store 네이밍 확인:
- 패턴: `defineStore`
- Glob 필터: `*.ts`
- 결과에서 `use.*Store` 패턴이 없는 행은 위반

### Step 6: 보고서 생성

Core 검증 결과와 Vue 3 Core 검증 결과를 통합하여 보고서를 출력합니다.

```markdown
## Vue 3 코드 컨벤션 검증 보고서

**검증 대상:** <경로>
**검증 일시:** <날짜>
**적용 규칙:** Core + Vue 3 Core

### 요약

| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| Core: G1-G5 | ... | ... | ... | ... |
| Vue Core: G1. SFC | 0 | 1 | 0 | ⚠️ |
| Vue Core: G2. Composition API | 0 | 2 | 0 | ⚠️ |
| Vue Core: G3. Pinia | 0 | 0 | 0 | ✅ |

### 상세 위반 목록

| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|
| 1 | Warning | G1.1 | src/components/Form.vue | 5 | script setup 미사용 | `<script setup lang="ts">` 사용 |
| ... | | | | | | |
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **Nuxt 컨벤션** — Nuxt의 auto-import, 파일 기반 라우팅, 디렉토리 구조 규칙
2. **Vuetify/Quasar 패턴** — UI 프레임워크가 요구하는 컴포넌트 사용 패턴
3. **Options API 마이그레이션** — Composition API로 점진적 마이그레이션 중인 코드
4. **테스트 코드** — 테스트에서의 간소화된 컴포넌트, mount 옵션
5. **레이아웃 파일** — `App.vue`, 레이아웃 컴포넌트의 특수 구조
6. **자동 생성 코드** — Nuxt의 `.nuxt/`, Vue CLI의 자동 설정 파일

## Related Files

| File | Purpose |
|------|---------|
| `code-convention/SKILL.md` | Core 규칙 (이 스킬의 기반) |
| `code-convention-vue3-patterns/SKILL.md` | 확장 규칙 (디렉티브, Router, 파일 구조, 보안) |
| `vite.config.*` | Vite 설정 |
| `tsconfig.json` | TypeScript 설정 |
| `src/stores/` | Pinia store 디렉토리 |
