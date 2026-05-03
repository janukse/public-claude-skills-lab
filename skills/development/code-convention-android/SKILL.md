---
name: code-convention-android
description: Android(Kotlin + Jetpack Compose/View) 코드 컨벤션 가이드 및 검증. Kotlin 언어 핵심 규칙(네이밍, Null Safety, 함수/람다, 코루틴, 에러 처리)과 Android UI/Lifecycle 규칙을 통합 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# Android (Kotlin) 코드 컨벤션

## 목적

Android 프로젝트(Kotlin + Jetpack Compose/View)에서 일관된 코드 품질을 유지하기 위한 **시맨틱 규칙** 시스템입니다:

1. **Guide 모드** — 코드 작성 시 컨벤션을 자동으로 따르도록 안내
2. **Verify 모드** — 기존 코드의 컨벤션 준수 여부를 검증하고 보고서 생성

ktlint/detekt가 처리하는 포매팅(들여쓰기, 줄바꿈, import 순서 등)은 제외하고, **의미론적 규칙**에 집중합니다. JetBrains [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)와 Google [Android Kotlin Style Guide](https://developer.android.com/kotlin/style-guide)를 기반으로 합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-android guide` | 코드 작성 시 규칙을 참조하여 적용 |
| Verify | `/code-convention-android verify app/src/` | 지정 경로의 코드를 검증하고 보고서 출력 |
| Verify (전체) | `/code-convention-android verify` | 프로젝트 전체 검증 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 크래시, 메모리 누수, NPE 위험, ANR 유발 |
| `[Warning]` | 권장 | 가독성, 일관성, Kotlin idiom 위반, 유지보수 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

---

## [Guide 모드] 코드 작성 규칙

### G1. 네이밍

#### G1.1 변수/함수/프로퍼티 (camelCase) [Error]

**규칙:** 변수, 함수, 프로퍼티는 lowerCamelCase를 사용합니다.

**Good:**
```kotlin
val userName: String = "Alice"
var retryCount: Int = 0
fun fetchUserProfile(userId: String): User? { /* ... */ }
```

**Bad:**
```kotlin
val user_name = "Alice"
val UserName = "Alice"
fun fetch_user_profile(userId: String): User? { /* ... */ }
```

#### G1.2 타입 (PascalCase) [Error]

**규칙:** 클래스, 인터페이스, object, typealias, enum class는 PascalCase를 사용합니다.

**Good:**
```kotlin
class UserRepository { /* ... */ }
interface Authenticator { /* ... */ }
object NetworkClient { /* ... */ }
enum class UserRole { ADMIN, MEMBER, GUEST }
typealias UserId = String
```

**Bad:** `class userRepository`, `interface authenticator`

#### G1.3 상수 (UPPER_SNAKE_CASE) [Error]

**규칙:** `const val`과 최상위/companion object의 불변 상수는 UPPER_SNAKE_CASE를 사용합니다. 일반 `val` 프로퍼티는 camelCase.

**이유:** JetBrains Kotlin Coding Conventions와 Android Style Guide가 모두 강하게 명시하며, ktlint가 강제하는 규칙입니다.

**Good:**
```kotlin
const val MAX_RETRY_COUNT = 3
const val API_BASE_URL = "https://api.example.com"

class UserService {
    companion object {
        private const val DEFAULT_TIMEOUT_MS = 5000L
    }
}
```

**Bad:** `const val maxRetryCount = 3`, `const val apiBaseUrl = "..."`

#### G1.4 enum entry (UPPER_SNAKE_CASE 또는 PascalCase) [Info]

**규칙:** enum entry는 **UPPER_SNAKE_CASE를 권장**하지만, JetBrains 공식 컨벤션은 **PascalCase(upper camelCase)도 허용**합니다. 팀 합의로 일관성 있게 한 가지를 선택합니다.

**이유:** Kotlin 공식 가이드는 "Enum constants: Depending on the usage, you can use either uppercase underscore-separated names (`enum class Color { RED, GREEN }`) or upper camel case names (`enum class Color { Red, Green }`)"라고 명시합니다. 단, 한 프로젝트 안에서는 일관되게 사용해야 합니다.

**Good (둘 다 허용):**
```kotlin
enum class NetworkError {
    TIMEOUT,
    INVALID_RESPONSE,
    UNAUTHORIZED,
}

// 또는
enum class Color { Red, Green, Blue }
```

**Bad (혼용):**
```kotlin
enum class Status { ACTIVE, Inactive, PENDING }   // 일관성 없음
```

#### G1.5 패키지명 (lowercase) [Warning]

**규칙:** 패키지명은 모두 소문자, 단어 구분에 underscore나 camelCase를 사용하지 않습니다.

**Good:** `com.example.userprofile`, `com.example.network`
**Bad:** `com.example.user_profile`, `com.example.userProfile`

#### G1.6 Boolean 네이밍 [Warning]

**규칙:** Boolean 프로퍼티/함수는 `is`, `has`, `can`, `should` 접두사를 사용합니다.

**Good:**
```kotlin
val isLoading: Boolean = true
val hasUnreadMessages: Boolean = user.unreadCount > 0
fun canEdit(user: User): Boolean { /* ... */ }
```

**Bad:** `val loading = true`, `val unread = true`

#### G1.7 @Composable 함수 (PascalCase) [Error]

**규칙:** `Unit`을 반환하는 `@Composable` 함수는 PascalCase를 사용합니다 (UI 요소를 만드는 "타입" 같은 역할). 값을 반환하는 Composable 함수(예: `remember*`)는 일반 함수처럼 camelCase를 사용합니다.

**이유:** Android Compose Style Guide의 명시적 규칙이며, ktlint compose 룰셋이 강제합니다. PascalCase는 호출부에서 UI 컴포넌트임을 즉시 인식하게 해줍니다.

**Good:**
```kotlin
@Composable
fun UserProfileCard(user: User, modifier: Modifier = Modifier) {   // PascalCase
    Card(modifier = modifier) {
        Text(user.name)
    }
}

@Composable
fun rememberUserState(userId: String): UserState {                  // 값 반환 → camelCase
    return remember(userId) { UserState(userId) }
}
```

**Bad:**
```kotlin
@Composable
fun userProfileCard(user: User) { /* ... */ }   // camelCase → 일반 함수처럼 보임
```

#### G1.8 파일명 [Warning]

**규칙:** 단일 클래스를 포함한 파일명은 클래스명과 일치(PascalCase + `.kt`). 최상위 함수/확장 모음 파일은 내용을 설명하는 PascalCase 파일명(예: `StringExtensions.kt`).

**Good:** `UserRepository.kt`, `StringExtensions.kt`
**Bad:** `user_repository.kt`, `userrepository.kt`

---

### G2. 타입과 Null Safety

#### G2.1 `!!` 연산자 사용 금지 [Error]

**규칙:** non-null assertion(`!!`)을 사용하지 않습니다. `?.`, `?:`, `let`, `requireNotNull`을 사용합니다.

**이유:** `!!`는 null일 때 NPE를 던져 크래시를 유발합니다. Kotlin의 null 안전성 이점을 무력화합니다.

**Good:**
```kotlin
val name = user?.profile?.displayName ?: "Guest"

user?.let { processUser(it) }

val id = requireNotNull(input.id) { "ID must not be null at this point" }
```

**Bad:**
```kotlin
val name = user!!.profile!!.displayName!!   // 어떤 게 null이어도 NPE
processUser(user!!)
```

#### G2.2 플랫폼 타입 명시 [Warning]

**규칙:** Java interop으로 받은 플랫폼 타입(`String!`)은 nullable(`String?`) 또는 non-null(`String`)로 명시적 선언합니다. Kotlin-friendly 어노테이션(`@Nullable`/`@NonNull`)이 없는 순수 Java API가 대상입니다.

**이유:** 플랫폼 타입은 컴파일러가 null 검사를 강제하지 않아 런타임 NPE를 유발할 수 있습니다. (참고: Android 프레임워크의 대부분 API는 어노테이션이 적용되어 nullable/non-null이 명확합니다.)

**Good:**
```kotlin
// 어노테이션 없는 Java API 호출 시 명시적 선언
val name: String? = legacyJavaService.getName()    // null 가능성 명시
val count: Int = legacyJavaService.getCount()      // non-null 단언

// 즉시 사용 시 nullable로 받고 안전하게 접근
val length: Int = legacyJavaService.getName()?.length ?: 0
```

**Bad:**
```kotlin
val name = legacyJavaService.getName()    // 플랫폼 타입 String! → 의도 불명
name.length                                // NPE 가능 (컴파일러 경고 없음)
```

#### G2.3 `var`보다 `val` 우선 [Warning]

**규칙:** 재할당이 필요하지 않으면 `val`을 사용합니다.

**Good:** `val user = User(name = "Alice")`
**Bad:** `var user = User(name = "Alice")` (재할당 없는데 var)

#### G2.4 data class 활용 [Info]

**규칙:** 값 객체(value object)는 `data class`를 사용합니다. `equals`/`hashCode`/`copy`/`toString`이 자동 생성됩니다.

**Good:**
```kotlin
data class User(val id: String, val name: String, val email: String)
```

**Bad:** 일반 `class User`로 정의 후 `equals`/`hashCode` 수동 구현

#### G2.5 sealed class/interface로 닫힌 계층 [Warning]

**규칙:** 유한한 변형이 있는 도메인은 `sealed class`/`sealed interface`로 표현합니다. when 식에서 컴파일러가 완전성을 검사합니다.

**Good:**
```kotlin
sealed interface UiState<out T> {
    data object Loading : UiState<Nothing>
    data class Success<T>(val data: T) : UiState<T>
    data class Error(val message: String) : UiState<Nothing>
}

when (state) {
    UiState.Loading -> showProgress()
    is UiState.Success -> showData(state.data)
    is UiState.Error -> showError(state.message)
}   // 모든 경우 처리, else 불필요
```

**Bad:** `enum class`로 데이터까지 표현하려 함, 또는 일반 sealed가 아닌 open class 계층

#### G2.6 Scope function 적절히 선택 [Info]

**규칙:** `let`/`run`/`with`/`apply`/`also`는 의도에 맞는 것을 사용합니다.

| 함수 | 컨텍스트 | 반환 | 용도 |
|------|---------|------|------|
| `let` | `it` | 람다 결과 | nullable 처리, 변환 |
| `run` | `this` | 람다 결과 | 객체 설정 + 결과 계산 |
| `apply` | `this` | 객체 자신 | 빌더식 객체 초기화 |
| `also` | `it` | 객체 자신 | 부수효과 (로깅 등) |
| `with` | `this` | 람다 결과 | non-null 객체에 여러 작업 |

**Good:** `User().apply { name = "Alice"; email = "..." }` (빌더 패턴)
**Bad:** 모든 경우에 `let`만 사용 → 의도 불명확

---

### G3. 함수와 람다

#### G3.1 단일 책임 원칙 [Warning]

**규칙:** 함수는 하나의 역할만 수행합니다. 함수 본문이 60줄을 초과하면 분리를 검토합니다 (detekt `LongMethod` 기본값 정렬: 60줄).

**Good:**
```kotlin
private fun isValidEmail(email: String): Boolean =
    email.matches(Regex("""^[^\s@]+@[^\s@]+\.[^\s@]+$"""))

fun createUser(input: CreateUserInput): User {
    require(isValidEmail(input.email)) { "Invalid email: ${input.email}" }
    return User(id = UUID.randomUUID().toString(), email = input.email, name = input.name)
}
```

#### G3.2 매개변수 개수 제한 [Warning]

**규칙:** 함수 매개변수는 3개 이하로 제한합니다. 그 이상이면 data class 매개변수 또는 builder를 사용합니다. Kotlin은 named argument로 완화되지만, 호출 시 의미 명확성에 한계가 있습니다.

**Good:**
```kotlin
data class SearchOptions(
    val query: String,
    val page: Int,
    val limit: Int,
    val sortBy: String? = null,
)

fun searchUsers(options: SearchOptions): List<User> { /* ... */ }
```

**Bad:**
```kotlin
fun searchUsers(query: String, page: Int, limit: Int, sortBy: String, order: String): List<User> { /* ... */ }
```

#### G3.3 Default 인자와 Named 인자 [Warning]

**규칙:** 오버로딩 대신 default 인자를 사용합니다. 호출 시 boolean/숫자 인자가 여러 개면 named argument로 가독성을 확보합니다.

**Good:**
```kotlin
fun show(message: String, duration: Int = Toast.LENGTH_SHORT, withIcon: Boolean = false) { /* ... */ }

show(message = "Saved", withIcon = true)   // named argument
```

**Bad:** `show("Saved", 0, true, false, true)` (positional 5개 → 의미 불명)

#### G3.4 Early Return 패턴 [Warning]

**규칙:** Guard로 조기 반환합니다. 중첩 if-else를 피합니다.

**Good:**
```kotlin
fun getDiscount(user: User): Int {
    if (!user.isActive) return 0
    if (!user.isPremium) return 5
    if (user.yearsOfMembership > 5) return 25
    return 15
}
```

**Bad:** 4단 중첩 if-else

#### G3.5 확장 함수는 의미 있는 도메인에만 [Warning]

**규칙:** 확장 함수는 해당 타입의 자연스러운 확장일 때만 사용합니다. 무관한 도메인 로직을 String/Int에 추가하지 않습니다.

**Good:**
```kotlin
fun String.isValidEmail(): Boolean = matches(Regex("""^[^\s@]+@[^\s@]+\.[^\s@]+$"""))
fun Context.dpToPx(dp: Int): Int = (dp * resources.displayMetrics.density).toInt()
```

**Bad:**
```kotlin
fun String.fetchUserFromServer(): User { /* ... */ }   // String의 책임이 아님
fun Int.sendAnalyticsEvent() { /* ... */ }
```

#### G3.6 람다 캡처와 메모리 누수 [Error]

**규칙:** 장기 생존 객체(Singleton, Application 스코프)에 등록하는 람다에서 Activity/Fragment/View를 캡처하지 않습니다.

**이유:** Activity가 람다에 캡처되면 Activity가 destroy되어도 GC되지 않아 메모리 누수가 발생합니다.

**Good:**
```kotlin
// Repository는 application 수명을 따르므로 외부 등록 안전
class UserRepository(private val userDao: UserDao) {
    fun observeUsers(): Flow<List<User>> = userDao.observeAll()
}

// Activity는 호출만 하고 등록은 ViewModel/Repository에 위임
class MyActivity : AppCompatActivity() {
    private val viewModel: MyViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.users.collect { renderUsers(it) }   // lifecycle 종료 시 자동 정리
            }
        }
    }
}
```

**Bad:**
```kotlin
class MyActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        SingletonManager.register { updateUI() }   // Singleton이 Activity 캡처 → leak
        EventBus.getDefault().register(this)        // 명시적 unregister 누락 시 leak
    }
}
```

---

### G4. 코루틴 (Coroutines)

#### G4.1 GlobalScope 사용 금지 [Error]

**규칙:** `GlobalScope`로 코루틴을 시작하지 않습니다. 적절한 스코프(`viewModelScope`, `lifecycleScope`, 사용자 정의 `CoroutineScope`)를 사용합니다.

**이유:** `GlobalScope`는 앱 전체 수명 동안 살아있어 cancellation을 받지 못하고 메모리 누수와 경합 상태를 유발합니다.

**Good:**
```kotlin
class MyViewModel : ViewModel() {
    fun loadData() {
        viewModelScope.launch {
            val data = repository.fetch()
            _uiState.value = UiState.Success(data)
        }
    }
}
```

**Bad:**
```kotlin
fun loadData() {
    GlobalScope.launch { /* ... */ }
}
```

#### G4.2 적절한 Dispatcher 선택 [Warning]

**규칙:** 작업 종류에 맞는 Dispatcher를 사용합니다.

| Dispatcher | 용도 |
|------------|------|
| `Dispatchers.Main` | UI 업데이트 |
| `Dispatchers.IO` | 네트워크, 디스크, DB |
| `Dispatchers.Default` | CPU 집약적 (정렬, 파싱, 이미지 처리) |
| `Dispatchers.Unconfined` | 거의 사용하지 않음 (테스트 외) |

**Good:** `withContext(Dispatchers.IO) { api.fetchUsers() }`
**Bad:** Main에서 무거운 JSON 파싱 → ANR 위험

#### G4.3 suspend 함수는 main-safe하게 [Warning]

**규칙:** `suspend` 함수는 어디서 호출하든 안전하게 동작해야 합니다. 내부에서 적절한 Dispatcher를 `withContext`로 감쌉니다.

**Good:**
```kotlin
suspend fun fetchUsers(): List<User> = withContext(Dispatchers.IO) {
    api.getUsers()
}
```

**Bad:** suspend 함수가 실제로는 Main 스레드에서 블로킹 작업 수행

#### G4.4 구조적 동시성 (Structured Concurrency) [Warning]

**규칙:** 자식 코루틴은 부모 스코프 내에서 시작합니다. 독립적인 launch를 남발하지 않습니다.

**Good:**
```kotlin
viewModelScope.launch {
    coroutineScope {
        val users = async { api.fetchUsers() }
        val posts = async { api.fetchPosts() }
        combine(users.await(), posts.await())
    }
}
```

**Bad:** 부모 스코프 없이 임의로 `CoroutineScope(Dispatchers.IO).launch { }` 생성

#### G4.5 Dispatcher 하드코딩 금지 (주입) [Warning]

**규칙:** `withContext(Dispatchers.IO)`처럼 Dispatcher를 함수 본문에 하드코딩하지 않고, 생성자나 함수 인자로 주입받습니다.

**이유:** Android 공식 best practice 1번 항목. 하드코딩하면 (1) 단위 테스트에서 `TestDispatcher`로 교체 불가, (2) Main-safe 보장이 호출자에게 숨겨지고, (3) 모듈별 dispatcher 정책 변경이 어렵습니다.

**Good:**
```kotlin
class UserRepository(
    private val api: UserApi,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,   // 주입 가능
) {
    suspend fun fetchUsers(): List<User> = withContext(ioDispatcher) {
        api.getUsers()
    }
}

// 테스트에서
val repo = UserRepository(api = fakeApi, ioDispatcher = StandardTestDispatcher())
```

**Bad:**
```kotlin
class UserRepository(private val api: UserApi) {
    suspend fun fetchUsers(): List<User> = withContext(Dispatchers.IO) {  // 하드코딩
        api.getUsers()
    }
}
```

**참고:** Hilt를 쓰는 프로젝트는 `@Qualifier`로 `IoDispatcher`/`MainDispatcher`/`DefaultDispatcher`를 분리 주입하는 것이 표준 패턴입니다.

#### G4.6 Flow 수집은 lifecycle-aware하게 [Error]

**규칙:** Activity/Fragment에서 Flow를 수집할 때 `repeatOnLifecycle` 또는 `flowWithLifecycle`을 사용합니다.

**이유:** 단순 `lifecycleScope.launch { flow.collect { } }`는 STOPPED 상태에서도 수집을 계속해 자원을 낭비합니다.

**Good:**
```kotlin
class MyFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                viewModel.uiState.collect { renderState(it) }
            }
        }
    }
}
```

**Bad:** `lifecycleScope.launch { viewModel.uiState.collect { ... } }` (lifecycle 무시)

---

### G5. 에러 처리

#### G5.1 도메인별 sealed 에러 타입 [Warning]

**규칙:** 도메인 에러는 `sealed class`/`sealed interface` + Exception 또는 Result 타입으로 표현합니다.

**Good:**
```kotlin
sealed class NetworkException(message: String) : Exception(message) {
    object Timeout : NetworkException("Request timed out")
    data class InvalidResponse(val statusCode: Int) : NetworkException("Status: $statusCode")
    data class Decoding(val cause: Throwable) : NetworkException("Failed to decode")
}
```

**Bad:** 일반 `RuntimeException("network error")`만 사용 → catch에서 분기 불가

#### G5.2 빈 catch 블록 금지 [Error]

**규칙:** 에러를 빈 catch로 무시하지 않습니다. 최소한 로깅을 수행합니다.

**Good:**
```kotlin
try {
    cache.write(data)
} catch (e: IOException) {
    logger.warn("Cache write failed", e)
    // 의도적으로 무시 — 캐시 실패는 critical 아님
}
```

**Bad:**
```kotlin
try { cache.write(data) } catch (e: Exception) { }
```

#### G5.3 Throwable/광범위 catch 금지 [Error 또는 Warning]

**규칙:** `catch (e: Throwable)` 또는 `catch (e: Exception)`으로 모든 예외를 무차별 잡지 않습니다. 구체적인 예외 타입을 잡습니다.

**심각도 결정:**
- **[Error]** — `suspend` 함수 내부, 코루틴 빌더(`launch`/`async`/`runBlocking`) 내부, `Flow.catch` 내부에서 광범위 catch
- **[Warning]** — 일반 동기 코드에서 광범위 catch (detekt `TooGenericExceptionCaught` 기준)

**이유:**
- 일반 코드에서: `Throwable`은 `OutOfMemoryError`, `StackOverflowError` 같은 복구 불가능한 에러까지 잡아 디버깅을 어렵게 만듭니다.
- 코루틴 내부에서: `CancellationException`까지 삼켜 cancellation이 동작하지 않습니다. 부모 스코프가 취소를 시도해도 자식 코루틴이 계속 실행되어 leak/race condition을 유발합니다 — 따라서 [Error] 등급.

**Good:**
```kotlin
// 구체 타입으로 catch
try {
    api.fetch()
} catch (e: IOException) {
    handleNetworkError(e)
} catch (e: SerializationException) {
    handleParseError(e)
}

// 코루틴 안에서 광범위 catch가 불가피하면 CancellationException 재던지기
suspend fun safeOperation() {
    try {
        riskyWork()
    } catch (e: CancellationException) {
        throw e   // 반드시 다시 던짐
    } catch (e: Exception) {
        logger.error("Operation failed", e)
    }
}
```

**Bad:**
```kotlin
suspend fun loadData() {
    try {
        val data = repository.fetch()
        process(data)
    } catch (e: Exception) {
        // [Error] — CancellationException 삼킴 → cancel 안 됨
        logger.error("Failed", e)
    }
}
```

**예외:** 최상위 글로벌 핸들러(`Thread.setDefaultUncaughtExceptionHandler`, `CoroutineExceptionHandler`)는 광범위 catch 허용 (단, 코루틴 핸들러에서도 `CancellationException`은 통과시킴).

#### G5.4 CancellationException 재던지기 (코루틴 협력적 취소) [Error]

**규칙:** 코루틴 / `suspend` 함수 내부에서 광범위 catch가 불가피하면 `CancellationException`은 반드시 다시 던집니다. 이는 `runCatching`을 사용할 때도 마찬가지입니다.

**이유:** 코루틴의 cancellation은 `CancellationException`을 throw해서 전파됩니다. 이를 catch하고 삼키면 `coroutineScope.cancel()`을 호출해도 자식 코루틴이 멈추지 않아 leak/race condition이 발생합니다. 이는 코루틴 "구조적 동시성"의 핵심 계약입니다.

**Good:**
```kotlin
suspend fun safeOperation(): Result<Data> {
    return try {
        Result.success(api.fetch())
    } catch (e: CancellationException) {
        throw e   // 반드시 재던짐
    } catch (e: Exception) {
        Result.failure(e)
    }
}

// runCatching도 동일하게 처리
suspend fun fetchData(): Result<Data> = runCatching {
    api.fetch()
}.onFailure { e ->
    if (e is CancellationException) throw e
}
```

**Bad:**
```kotlin
suspend fun loadData() {
    try {
        repository.fetch()
    } catch (e: Exception) {
        log("Failed", e)   // CancellationException까지 삼킴 → cancel 안 됨
    }
}

// runCatching도 위험 (CancellationException까지 Result에 담음)
suspend fun fetchData() = runCatching { api.fetch() }   // ❌
```

#### G5.5 Result 타입 활용 [Info]

**규칙:** 실패가 흔한 비즈니스 흐름은 예외보다 `Result<T>` 또는 sealed `Either`로 표현합니다. 예외는 진짜 예외적 상황에 사용합니다.

**Good:**
```kotlin
suspend fun fetchUser(id: String): Result<User> = runCatching {
    api.getUser(id)
}

fetchUser(id)
    .onSuccess { renderUser(it) }
    .onFailure { showError(it) }
```

#### G5.6 require/check/error 사용 [Warning]

**규칙:** 사전 조건은 `require`(인자 검증, IllegalArgumentException), 상태 검증은 `check`(IllegalStateException), 도달 불가 분기는 `error("...")`를 사용합니다.

**Good:**
```kotlin
fun divide(a: Int, b: Int): Int {
    require(b != 0) { "Divisor must not be zero" }
    return a / b
}

fun nextStep() {
    check(initialized) { "Must call initialize() first" }
    // ...
}
```

---

### G6. Android UI 및 Lifecycle

#### G6.1 Compose: 상태 호이스팅 [Warning]

**규칙:** Composable의 상태는 가능한 한 호출자로 끌어올립니다(state hoisting). 재사용성과 테스트 용이성이 향상됩니다.

**Good:**
```kotlin
@Composable
fun NameField(name: String, onNameChange: (String) -> Unit) {
    TextField(value = name, onValueChange = onNameChange)
}

// 호출부
var name by rememberSaveable { mutableStateOf("") }
NameField(name = name, onNameChange = { name = it })
```

**Bad:**
```kotlin
@Composable
fun NameField() {
    var name by remember { mutableStateOf("") }   // 내부에 상태 → 외부에서 제어 불가
    TextField(value = name, onValueChange = { name = it })
}
```

#### G6.2 Compose: remember/rememberSaveable 선택 [Warning]

**규칙:** 구성 변경(회전 등)에서 보존이 필요한 상태는 `rememberSaveable`을, 일시적 UI 상태는 `remember`를 사용합니다.

**이유:** 잘못 선택하면 회전 시 사용자 입력이 사라지는 UX 결함이 발생합니다 (크래시/누수가 아니므로 [Warning]).

**Good:**
```kotlin
var query by rememberSaveable { mutableStateOf("") }   // 회전 후에도 유지
val scrollState = rememberScrollState()                 // 일시적 UI 상태
```

**Bad:** 사용자 입력 텍스트를 `remember`로만 보존 → 회전 시 사라짐

#### G6.3 Compose: 부수효과는 LaunchedEffect [Error]

**규칙:** Composable 안에서 부수효과(네트워크 호출, 코루틴 실행 등)는 `LaunchedEffect`/`DisposableEffect`/`SideEffect`로 분리합니다. body에서 직접 호출하지 않습니다.

**이유:** Composable body는 recomposition마다 실행되어 부수효과가 무한히 트리거됩니다.

**Good:**
```kotlin
@Composable
fun UserScreen(userId: String, viewModel: UserViewModel) {
    LaunchedEffect(userId) {
        viewModel.load(userId)
    }
    // ...
}
```

**Bad:**
```kotlin
@Composable
fun UserScreen(userId: String, viewModel: UserViewModel) {
    viewModel.load(userId)   // recomposition마다 호출됨!
}
```

#### G6.4 Compose: List는 key 지정 [Warning]

**규칙:** `LazyColumn`/`LazyRow`의 `items`에 `key`를 지정합니다.

**이유:** key가 없으면 항목 순서 변경 시 잘못된 애니메이션과 상태 손실이 발생합니다.

**Good:**
```kotlin
LazyColumn {
    items(users, key = { it.id }) { user ->
        UserRow(user)
    }
}
```

**Bad:** `items(users) { user -> UserRow(user) }` (key 누락)

#### G6.5 Activity/Fragment 메모리 누수 방지 [Error]

**규칙:** 다음을 준수하여 Activity/Fragment 누수를 방지합니다.

- Static/Singleton에서 Activity Context를 보관하지 않음 (`applicationContext` 사용)
- Fragment에서 view 참조는 `onDestroyView`에서 null 처리 (또는 viewBinding 패턴)
- Handler/Runnable의 콜백은 `removeCallbacks`로 정리
- BroadcastReceiver는 `unregisterReceiver`로 정리

**Good:**
```kotlin
class MyFragment : Fragment() {
    private var _binding: FragmentMyBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(...): View {
        _binding = FragmentMyBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null   // 누수 방지
    }
}
```

#### G6.6 ViewModel은 Android 의존성 보유 금지 [Error]

**규칙:** `ViewModel`에 `Context`, `View`, `Activity`, `Fragment` 참조를 보관하지 않습니다. 필요하면 `AndroidViewModel(application)` 사용.

**이유:** ViewModel은 구성 변경을 견디므로 Activity 참조를 보관하면 leak이 발생합니다.

**Good:**
```kotlin
class UserViewModel(
    private val repository: UserRepository,
) : ViewModel() { /* ... */ }
```

**Bad:**
```kotlin
class UserViewModel(
    private val activity: MainActivity,   // leak!
) : ViewModel() { /* ... */ }
```

#### G6.7 ViewModel: Mutable 타입 외부 노출 금지 (Backing property) [Error]

**규칙:** ViewModel 내부에서는 `MutableStateFlow`/`MutableLiveData`/`MutableSharedFlow`로 상태를 변경하되, 외부에는 read-only 타입(`StateFlow`/`LiveData`/`SharedFlow`)으로만 노출합니다. backing property 패턴(`_name` private + `name` public)을 사용합니다.

**이유:** Android ViewModel 패턴의 핵심 계약. UI 계층이 상태를 직접 변경하면 ViewModel이 단일 진실 공급원(SSOT)이 되지 못해 race condition과 추적 불가능한 상태 변경이 발생합니다.

**Good:**
```kotlin
class UserListViewModel : ViewModel() {
    private val _uiState = MutableStateFlow<UiState<List<User>>>(UiState.Loading)
    val uiState: StateFlow<UiState<List<User>>> = _uiState.asStateFlow()

    private val _events = MutableSharedFlow<UiEvent>()
    val events: SharedFlow<UiEvent> = _events.asSharedFlow()

    fun load() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            _uiState.value = runCatching { repository.fetchUsers() }
                .fold({ UiState.Success(it) }, { UiState.Error(it.message ?: "") })
        }
    }
}
```

**Bad:**
```kotlin
class UserListViewModel : ViewModel() {
    val uiState = MutableStateFlow<UiState<List<User>>>(UiState.Loading)   // ❌ Mutable 노출
    // → UI에서 viewModel.uiState.value = ... 로 변경 가능 → SSOT 깨짐
}
```

#### G6.8 Compose: Flow 수집은 collectAsStateWithLifecycle [Warning]

**규칙:** Compose에서 `Flow`를 `State`로 변환할 때 `collectAsStateWithLifecycle()`을 사용합니다. `collectAsState()`는 lifecycle을 무시합니다.

**이유:** `collectAsState()`는 Composition이 살아있는 동안 계속 수집하므로, Activity/Fragment가 STOPPED 상태(예: 백그라운드)에서도 자원을 소모합니다. `collectAsStateWithLifecycle()`은 lifecycle이 STARTED 이상일 때만 수집합니다.

**Good:**
```kotlin
@Composable
fun UserListScreen(viewModel: UserListViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    UserListContent(uiState = uiState)
}
```

**Bad:**
```kotlin
@Composable
fun UserListScreen(viewModel: UserListViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsState()   // 백그라운드에서도 수집
}
```

**참고:** `androidx.lifecycle:lifecycle-runtime-compose` 의존성이 필요합니다.

#### G6.9 ViewModel: suspend 함수 외부 노출 금지 [Warning]

**규칙:** ViewModel은 비즈니스 로직을 `viewModelScope.launch` 안에서 실행하고, UI에는 일반 함수와 상태 흐름(`StateFlow`)을 노출합니다. `suspend fun load()`처럼 UI가 직접 호출해야 하는 suspend 함수를 노출하지 않습니다.

**이유:** Android 공식 가이드: UI 계층이 코루틴 스코프와 cancellation을 책임지면 구성 변경 시 작업이 중단됩니다. ViewModel이 자신의 `viewModelScope` 안에서 작업을 수행해야 ViewModel 수명을 따릅니다.

**Good:**
```kotlin
class UserViewModel : ViewModel() {
    fun load() {
        viewModelScope.launch {
            _uiState.value = UiState.Success(repository.fetchUsers())
        }
    }
}

// UI는 일반 함수로 호출
LaunchedEffect(Unit) { viewModel.load() }
```

**Bad:**
```kotlin
class UserViewModel : ViewModel() {
    suspend fun load() = repository.fetchUsers()   // UI가 스코프를 책임지게 됨
}

// UI에서
LaunchedEffect(Unit) { viewModel.load() }   // composition 취소 시 작업 중단
```

#### G6.10 리소스 ID/문자열 [Warning]

**규칙:** UI 문자열은 `strings.xml`에 정의하고 `getString(R.string.xxx)`로 참조합니다. 코드에 하드코딩하지 않습니다.

**이유:** 다국어 지원, 일관성, 검색 용이성.

**Good:** `Toast.makeText(context, R.string.save_success, Toast.LENGTH_SHORT).show()`
**Bad:** `Toast.makeText(context, "저장되었습니다", Toast.LENGTH_SHORT).show()`

---

## [Verify 모드] 코드 검증 워크플로우

Verify 모드는 지정된 파일/디렉토리의 Kotlin 코드를 G1-G6 규칙으로 검증하고 보고서를 생성합니다.

> **보고서 작성 규칙:** 위반 항목의 규칙 컬럼은 fully-qualified 형식 `code-convention-android:G<번호>`을 사용합니다.

### Step 1: 검증 대상 수집

Glob으로 대상 파일을 수집합니다:
- 패턴: `**/*.kt`
- `build/`, `.gradle/`, `generated/` 디렉토리는 제외
- 자동 생성 파일 (`*Binding.kt`, `*_Impl.kt`, Hilt/Dagger 생성물) 면제

### Step 2: G1 네이밍 검사

Grep으로 snake_case 변수/함수 탐지:
- 패턴: `(val|var|fun) [a-z][a-zA-Z0-9]*_[a-z]`
- Glob 필터: `*.kt`
- **면제:** `@JvmName("snake_case")`로 Java interop 명시
- **면제:** `@SerializedName`/`@Json`/`@PropertyName` 어노테이션 인접 (외부 JSON 매핑)
- **면제:** Room `@ColumnInfo(name = "snake_case")` 인접

타입 네이밍:
- 패턴: `(class|interface|object) [a-z]` (소문자로 시작하는 타입 정의)

### Step 3: G2 Null Safety 검사

`!!` 연산자 탐지:
- 패턴: `!![\s.,;\)\)\]]` 또는 `[a-zA-Z0-9_\)]\!\!`
- Glob 필터: `*.kt`
- **면제:** 단위 테스트 파일 (`*Test.kt`, `*Tests.kt`)
- **면제:** Fragment의 `private val binding get() = _binding!!` 패턴 (관례적 viewBinding)
- **면제:** 주석 라인

### Step 4: G3 함수/람다 검사

함수 길이 검사:
- 각 파일을 Read로 읽어 `fun `으로 시작하는 함수의 본문 길이 측정
- 30줄 초과 시 [Warning]

매개변수 개수 검사:
- 패턴: `fun \w+\([^)]{200,}\)` (긴 매개변수 목록 휴리스틱)
- Read로 확인 후 4개 이상이면 보고

### Step 5: G4 코루틴 검사

`GlobalScope` 탐지:
- 패턴: `GlobalScope\.(launch|async)`
- 결과는 [Error]로 보고

lifecycle-aware하지 않은 Flow collect 의심:
- 패턴: `lifecycleScope\.launch\s*\{[\s\S]{0,200}\.collect`
- 단, 같은 블록 안에 `repeatOnLifecycle` 또는 `flowWithLifecycle`이 있으면 면제
- 결과는 [Warning]으로 보고하고 Read로 확인 권장

Dispatcher 하드코딩 의심 (G4.5):
- 패턴: `withContext\(Dispatchers\.(IO|Default)\)`
- Repository/UseCase 클래스에서 발견되면 [Warning]으로 보고 (생성자 주입 권장)
- **면제:** Application 초기화 코드, 단발성 유틸 함수

### Step 6: G5 에러 처리 검사

빈 catch 탐지:
- 패턴: `catch\s*\([^)]*\)\s*\{\s*\}`
- 결과는 [Error]로 보고

광범위 catch 탐지:
- 패턴: `catch\s*\(\s*\w+\s*:\s*(Throwable|Exception)\s*\)`
- 같은 함수가 `suspend`이거나 `viewModelScope`/`lifecycleScope`/`coroutineScope` 블록 안이면 [Error] (CancellationException 삼킴 위험)
- 그 외 일반 동기 코드에서는 [Warning] (detekt `TooGenericExceptionCaught`)
- **면제:** 글로벌 에러 핸들러 (`Thread.setDefaultUncaughtExceptionHandler`, `CoroutineExceptionHandler` 인접)

CancellationException 재던지기 누락 (G5.4):
- 패턴: `suspend\s+fun\s+\w+[\s\S]{0,500}catch\s*\(\s*\w+\s*:\s*Exception\s*\)`
- 매칭된 catch 블록 안에 `if.*CancellationException` 또는 `is CancellationException` 분기가 없으면 [Error]로 보고

`runCatching` 사용 위험 (G5.4):
- 패턴: `suspend\s+fun[\s\S]{0,300}runCatching\s*\{`
- `onFailure` 안에 `CancellationException` 재throw가 없으면 [Warning]

### Step 7: G6 Android UI/Lifecycle 검사

Compose body에서 직접 부수효과 의심:
- 패턴: `@Composable\s+fun\s+\w+[\s\S]{0,500}viewModel\.\w+\(` (Composable 내 ViewModel 함수 직접 호출)
- LaunchedEffect/DisposableEffect 컨텍스트 안이 아니면 [Error]

ViewModel의 Activity/Context 참조 의심:
- 패턴: `class \w+ViewModel.*:\s*ViewModel.*\{[\s\S]{0,500}(Activity|Fragment|Context)\b`
- **면제:** `applicationContext`, `AndroidViewModel`
- 결과는 [Error]로 보고

LazyColumn/LazyRow key 누락:
- 패턴: `items\(\s*\w+\s*\)\s*\{` (key 파라미터 없는 items 호출)
- 결과는 [Warning]으로 보고

ViewModel Mutable 노출 의심 (G6.7):
- 패턴: `class \w+ViewModel.*:\s*ViewModel.*\{[\s\S]{0,1000}val\s+\w+\s*=\s*Mutable(StateFlow|SharedFlow|LiveData)`
- private 키워드가 없으면 [Error]로 보고 (backing property 패턴 위반)

@Composable 함수 네이밍 위반 (G1.7):
- 패턴: `@Composable[\s\n]+(?:internal\s+|private\s+|public\s+)?fun\s+[a-z]\w*\s*\([^)]*\)\s*(?::\s*Unit)?\s*\{` (Unit 반환 또는 명시 없음)
- 결과는 [Error]로 보고

Compose Flow 수집 lifecycle 누락 (G6.8):
- 패턴: `\.collectAsState\(\)` (Lifecycle 미사용)
- 결과는 [Warning]으로 보고 — `collectAsStateWithLifecycle()`로 교체 권장

### Step 8: 보고서 생성

```markdown
## Android 코드 컨벤션 검증 보고서 (code-convention-android:G1-G6)
**검증 대상:** <경로> | **검증 일시:** <날짜> | **검증 파일 수:** <N개>

### 요약
| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| G1 네이밍 | N | N | N | ✅/⚠️/❌ |
| G2 Null Safety | N | N | N | ✅/⚠️/❌ |
| G3 함수/람다 | N | N | N | ✅/⚠️/❌ |
| G4 코루틴 | N | N | N | ✅/⚠️/❌ |
| G5 에러 처리 | N | N | N | ✅/⚠️/❌ |
| G6 UI/Lifecycle | N | N | N | ✅/⚠️/❌ |
| **합계** | **N** | **N** | **N** | — |

### 상세 위반 목록
| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|

상태 기준: ✅ Error 0 & Warning 0 / ⚠️ Error 0 & Warning 1+ / ❌ Error 1+
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **외부 JSON/DB 매핑** — Gson/Moshi `@SerializedName`, Room `@ColumnInfo`로 매핑되는 snake_case 필드
2. **Java interop 시그니처** — `@JvmName`, `@JvmStatic`, `@JvmField`로 Java 호환을 위한 네이밍
3. **자동 생성 코드** — ViewBinding, DataBinding, Hilt/Dagger, KSP/KAPT 생성물
4. **단위 테스트의 `!!`** — 테스트 setup에서 의도적 사용 (실패 시 즉시 알림)
5. **viewBinding 패턴의 `_binding!!`** — Fragment의 일반적 관례
6. **글로벌 에러 핸들러** — `Thread.setDefaultUncaughtExceptionHandler`의 광범위 catch
7. **레거시 Java 코드와의 점진적 혼재** — 마이그레이션 중인 코드 (새 Kotlin 코드에는 규칙 적용)

## Related Files

| File | Purpose |
|------|---------|
| `.editorconfig` | ktlint/IDE 포매팅 설정 |
| `detekt.yml` | detekt 정적 분석 설정 |
| `build.gradle.kts` / `build.gradle` | 프로젝트 구조, 의존성 |
| JetBrains [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html) | 본 스킬 네이밍 규칙 출처 |
| Google [Android Kotlin Style Guide](https://developer.android.com/kotlin/style-guide) | Android 특화 규칙 출처 |
