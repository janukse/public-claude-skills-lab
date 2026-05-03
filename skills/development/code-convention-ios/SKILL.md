---
name: code-convention-ios
description: iOS(Swift + SwiftUI/UIKit) 코드 컨벤션 가이드 및 검증. Swift 언어 핵심 규칙(네이밍, 옵셔널, 함수/클로저, 메모리 관리, 에러 처리)과 iOS UI 프레임워크 규칙을 통합 제공합니다.
argument-hint: "[guide|verify] [선택: 파일 경로 또는 glob 패턴]"
---

# iOS (Swift) 코드 컨벤션

## 목적

iOS 프로젝트(Swift + SwiftUI/UIKit)에서 일관된 코드 품질을 유지하기 위한 **시맨틱 규칙** 시스템입니다:

1. **Guide 모드** — 코드 작성 시 컨벤션을 자동으로 따르도록 안내
2. **Verify 모드** — 기존 코드의 컨벤션 준수 여부를 검증하고 보고서 생성

SwiftLint/SwiftFormat이 처리하는 포매팅(들여쓰기, 줄바꿈, 콜론 간격 등)은 제외하고, **의미론적 규칙**에 집중합니다. Apple의 [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)를 기반으로 합니다.

## 모드 선택

| 모드 | 명령 예시 | 설명 |
|------|-----------|------|
| Guide | `/code-convention-ios guide` | 코드 작성 시 규칙을 참조하여 적용 |
| Verify | `/code-convention-ios verify Sources/` | 지정 경로의 코드를 검증하고 보고서 출력 |
| Verify (전체) | `/code-convention-ios verify` | 프로젝트 전체 검증 |

## 심각도 기준

| 심각도 | 의미 | 기준 |
|--------|------|------|
| `[Error]` | 필수 | 크래시, 메모리 누수, 강제 언래핑, 런타임 안전성 저해 |
| `[Warning]` | 권장 | 가독성, 일관성, Swift idiom 위반, 유지보수 영향 |
| `[Info]` | 참고 | 모범 사례, 개선 제안 |

---

## [Guide 모드] 코드 작성 규칙

### G1. 네이밍

#### G1.1 변수/함수/메서드 (lowerCamelCase) [Error]

**규칙:** 변수, 상수, 함수, 메서드는 lowerCamelCase를 사용합니다.

**이유:** Swift API Design Guidelines의 표준 컨벤션이며, 표준 라이브러리와 일관됩니다.

**Good:**
```swift
let userName = "Alice"
var retryCount = 0
func fetchUserProfile(userId: String) -> User? { /* ... */ }
```

**Bad:**
```swift
let user_name = "Alice"
let UserName = "Alice"
func FetchUserProfile(userId: String) -> User? { /* ... */ }
```

#### G1.2 타입 (UpperCamelCase) [Error]

**규칙:** 클래스, 구조체, enum, protocol, typealias는 UpperCamelCase를 사용합니다.

**Good:**
```swift
class UserService { /* ... */ }
struct UserProfile { /* ... */ }
enum UserRole { case admin, member, guest }
protocol Authenticatable { /* ... */ }
typealias UserId = String
```

**Bad:** `class userService`, `struct user_profile`, `enum userRole`

#### G1.3 enum case (lowerCamelCase) [Warning]

**규칙:** enum case는 lowerCamelCase를 사용합니다 (Swift 3+ 컨벤션).

**Good:**
```swift
enum NetworkError {
    case timeout
    case invalidResponse
    case unauthorized
}
```

**Bad:** `case Timeout`, `case INVALID_RESPONSE`

#### G1.4 Omit Needless Words (불필요한 단어 제거) [Warning]

**규칙:** 메서드/함수 이름에서 타입 정보로 추론 가능한 중복 단어를 제거합니다. 호출부 인자에서 의미가 드러나면 메서드명에 반복하지 않습니다.

**이유:** Swift API Design Guidelines의 1순위 원칙(`"Every word in a name should convey salient information at the use site"`). 표준 라이브러리 전반에 적용된 패턴입니다.

**Good:**
```swift
allViews.remove(cancelButton)            // remove(_:)
employees.remove(at: 5)                  // remove(at:)
list.append(newElement)                  // append(_:)
```

**Bad:**
```swift
allViews.removeElement(cancelButton)     // "Element"는 타입에서 자명
employees.removeElementAtIndex(5)        // "Element", "AtIndex" 모두 중복
list.appendElement(newElement)
```

#### G1.5 메서드 시그니처 자연어 가독성 [Warning]

**규칙:** 메서드 호출이 영어 문장처럼 읽히도록 인자 레이블과 메서드명을 설계합니다. 첫 인자에 전치사가 자연스러우면 외부 레이블로 분리합니다.

**이유:** Apple API Design Guidelines의 "fluent usage" 원칙. 호출부에서 의미가 자연스럽게 흘러야 합니다.

**Good:**
```swift
x.insert(y, at: z)            // "x, insert y at z"
view.dismiss(animated: true)  // "view, dismiss animated true"
allViews.remove(cancelButton, animated: true)
string.append(contentsOf: "world")
```

**Bad:**
```swift
x.insert(y, position: z)      // "position"이 어색 → "at"이 자연스러움
view.dismissWithAnimation(true)
```

#### G1.6 Protocol 네이밍 규칙 [Warning]

**규칙:** Protocol 이름은 의미에 따라 두 형태 중 선택합니다.
- **"무엇인가" (what it is)** → 명사 (`Collection`, `Sequence`, `Iterator`)
- **"능력/기능" (what it does)** → `-able`, `-ible`, `-ing` 접미사 (`Equatable`, `Hashable`, `ProgressReporting`)

**이유:** 표준 라이브러리 일관성. `UserManager` 같은 모호한 명사 protocol은 의도가 불명확합니다.

**Good:**
```swift
protocol Collection { /* 무엇인가 */ }
protocol Equatable { /* 비교 가능한 능력 */ }
protocol Cacheable { /* 캐시 가능한 능력 */ }
```

**Bad:**
```swift
protocol UserManager { /* 명사인지 능력인지 불명 */ }
protocol Cache { /* 능력인데 명사형 → Cacheable이 명확 */ }
```

#### G1.7 약어 대소문자 일관성 [Warning]

**규칙:** 약어(URL, HTML, ID, JSON 등)는 한 단어 내에서 모두 같은 case로 처리합니다.

**이유:** `UrlString`, `HtmlParser`처럼 약어 일부만 대문자로 쓰면 가독성이 떨어지고 SwiftLint `identifier_name`이 잡지 못하는 사각지대입니다.

**Good:** `urlString`, `htmlParser`, `userID`, `jsonData`, `URLSession` (타입 시작이면 모두 대문자)
**Bad:** `UrlString`, `HtmlParser`, `userId` (대소문자 일관성 깨짐)

#### G1.8 명료성 우선 (Clarity over Brevity) [Warning]

**규칙:** 약어보다 의도가 드러나는 이름을 선호합니다. 인자 레이블로 호출 시점의 가독성을 확보합니다.

**이유:** Swift API Design Guidelines의 핵심 원칙입니다. 호출부에서 자연스럽게 읽혀야 합니다.

**Good:**
```swift
func remove(at index: Int) { /* ... */ }
employees.remove(at: 5)

func insert(_ element: Element, at index: Int) { /* ... */ }
list.insert("apple", at: 0)
```

**Bad:**
```swift
func rm(_ idx: Int) { /* ... */ }   // 약어 남용
employees.rm(5)                      // 호출부에서 의미 불명

func ins(_ x: Element, _ i: Int) { /* ... */ }
list.ins("apple", 0)                 // 인자 의미 불명
```

#### G1.9 Boolean 네이밍 [Warning]

**규칙:** Boolean 프로퍼티/메서드는 단언문(assertion)으로 읽히도록 `is`, `has`, `can`, `should` 접두사 또는 형용사를 사용합니다.

**Good:**
```swift
var isEmpty: Bool
var hasUnreadMessages: Bool
var canEdit: Bool
func shouldRetry(after error: Error) -> Bool { /* ... */ }
```

**Bad:** `var empty: Bool`, `var loading: Bool`

#### G1.10 부수효과 동사형 / 비부수효과 명사형 [Info]

**규칙:** 부수효과가 있는 메서드는 동사형(`sort()`), 비부수효과는 명사형(`sorted()`)으로 명명합니다.

**Good:** `array.sort()` (in-place 변경) vs `array.sorted()` (새 배열 반환)
**Good:** `view.layoutIfNeeded()` (변경) vs `view.intrinsicContentSize` (조회)

#### G1.11 파일명 [Warning]

**규칙:** 파일명은 주된 타입의 이름과 일치시킵니다 (UpperCamelCase + `.swift`).

**Good:** `UserService.swift` (포함된 타입: `UserService`)
**Bad:** `user_service.swift`, `userservice.swift`

---

### G2. 옵셔널과 타입

#### G2.1 강제 언래핑 금지 [Error]

**규칙:** `!` 강제 언래핑(force unwrap)을 사용하지 않습니다. `if let`, `guard let`, `??`, 옵셔널 체이닝을 사용합니다.

**이유:** 강제 언래핑은 nil일 때 즉시 크래시를 유발합니다. iOS 앱 크래시의 주요 원인입니다.

**Good:**
```swift
guard let user = currentUser else { return }
let name = user.profile?.displayName ?? "Guest"
if let url = URL(string: urlString) {
    UIApplication.shared.open(url)
}
```

**Bad:**
```swift
let user = currentUser!                          // nil이면 즉시 크래시
let name = user.profile!.displayName!            // 연쇄 강제 언래핑
UIApplication.shared.open(URL(string: urlString)!)
```

**예외:** `@IBOutlet`은 관례상 `!` 허용 (스토리보드 연결이 보장될 때만).

#### G2.2 강제 타입 캐스팅 금지 [Error]

**규칙:** `as!` 강제 다운캐스팅을 사용하지 않습니다. `as?`와 `guard let`을 사용합니다.

**Good:**
```swift
guard let cell = collectionView.dequeueReusableCell(
    withReuseIdentifier: "Cell", for: indexPath
) as? MyCell else { return UICollectionViewCell() }
```

**Bad:** `let cell = collectionView.dequeueReusableCell(...) as! MyCell`

#### G2.3 옵셔널 체이닝과 nil 병합 활용 [Warning]

**규칙:** 깊은 옵셔널 접근은 `?.`과 `??`로 간결하게 표현합니다. `if let` 중첩(피라미드)을 피합니다.

**Good:**
```swift
let cityName = user?.address?.city?.name ?? "Unknown"

guard let user = currentUser,
      let address = user.address,
      let city = address.city else { return }
```

**Bad:**
```swift
if let user = currentUser {
    if let address = user.address {
        if let city = address.city {
            if let name = city.name {
                // 4단 중첩
            }
        }
    }
}
```

#### G2.4 Implicitly Unwrapped Optional 제한 [Error]

**규칙:** `String!` 같은 묵시적 언래핑 옵셔널(IUO)은 `@IBOutlet`과 같은 관례적 면제 케이스에만 허용합니다. 일반 프로퍼티는 `String?` 또는 non-optional을 사용합니다.

**이유:** IUO는 접근 시점에 자동으로 강제 언래핑되므로 G2.1과 **동일한 nil 크래시 위험**을 가집니다. 컴파일러가 검사를 우회할 뿐 런타임 위험은 같습니다.

**Good:** `var name: String?` 또는 `let name: String`
**Bad:** `var name: String!` (이유 없는 IUO)

**예외:** `@IBOutlet weak var label: UILabel!` — 스토리보드 연결 보장 관례, `lateinit`성 DI 프로퍼티 (테스트 setUp에서 주입 보장).

#### G2.5 var보다 let 우선 [Warning]

**규칙:** 재할당이 필요하지 않으면 `let`을 사용합니다. 컴파일러가 불변성을 보장합니다.

**Good:** `let user = User(name: "Alice")` (이후 변경 없음)
**Bad:** `var user = User(name: "Alice")` (변경 안 하는데 var)

#### G2.6 타입 추론 활용 [Info]

**규칙:** 명백한 타입은 추론에 맡깁니다. 불명확하거나 의도된 타입이 다를 때만 명시합니다.

**Good:** `let count = 0` (Int 자명), `let total: Double = 0` (의도적으로 Double)
**Bad:** `let count: Int = 0` (불필요한 명시)

---

### G3. 함수와 클로저

#### G3.1 단일 책임 원칙 [Warning]

**규칙:** 함수는 하나의 역할만 수행합니다. 함수 본문이 40줄을 초과하면 분리를 검토합니다 (SwiftLint `function_body_length` 기본값 정렬: warning 40 / error 100).

**Good:**
```swift
func validateEmail(_ email: String) -> Bool {
    let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
    return email.range(of: pattern, options: .regularExpression) != nil
}

func createUser(input: CreateUserInput) throws -> User {
    guard validateEmail(input.email) else {
        throw ValidationError.invalidEmail(input.email)
    }
    return User(id: UUID(), email: input.email, name: input.name)
}
```

#### G3.2 인자 레이블 활용 [Warning]

**규칙:** 호출 시점에 자연스러운 영어 문장처럼 읽히도록 인자 레이블을 설계합니다. 첫 인자에 전치사가 필요하면 외부 레이블로 분리합니다.

**Good:**
```swift
func move(from source: Index, to destination: Index) { /* ... */ }
list.move(from: 0, to: 5)

func append(_ newElement: Element) { /* ... */ }   // _ 사용 (자명)
list.append("apple")
```

**Bad:**
```swift
func move(_ source: Index, _ destination: Index) { /* ... */ }
list.move(0, 5)   // 0이 from인지 to인지 불명
```

#### G3.3 trailing closure 적절히 사용 [Info]

**규칙:** 클로저가 마지막 인자이고 본문이 길면 trailing closure 문법을 사용합니다. 단, 의미가 모호해지면 레이블을 유지합니다.

**Good:**
```swift
let sorted = numbers.sorted { $0 < $1 }

UIView.animate(withDuration: 0.3) {
    view.alpha = 0
}
```

**Bad:** 호출 의미가 모호해지는 trailing closure 남용

#### G3.4 [weak self] 캡처 [Error]

**규칙:** **장기 보관되는** escaping closure에서 `self`를 캡처할 때 `[weak self]`를 사용합니다. 구체적으로 다음 경우에 적용합니다:
- `self`가 보유한 객체에 클로저가 등록되는 경우 (NotificationCenter, Timer, Combine subscription, delegate 콜백)
- 반복 호출되며 오래 살아있는 콜백 (스트림, observation, 장기 publisher)

**이유:** 장기 보관 escaping closure가 self를 strong 캡처하면 self ↔ closure 사이에 retain cycle이 형성되어 메모리 누수가 발생합니다.

**Good:**
```swift
NotificationCenter.default.addObserver(
    forName: .didLogin, object: nil, queue: .main
) { [weak self] _ in
    self?.refresh()   // 장기 보관 → weak 필수
}

cancellable = publisher.sink { [weak self] value in
    self?.update(value)
}
```

**Bad:**
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
    self.tick()    // self ↔ timer ↔ self cycle
}
```

**예외 (weak 불필요):**
- non-escaping closure (`map`, `filter`, `forEach`, `sorted`) — 호출 즉시 종료되어 cycle 형성 불가
- 일회성 escaping closure가 즉시 해제되는 경우 (`URLSession.dataTask` 단발성 completion, `DispatchQueue.async` 1회 실행) — 콜백 종료 시 캡처도 함께 해제됨
- `Task { ... }` 내부 — Task가 끝나면 캡처 해제 (단, Task를 프로퍼티로 보관하면 weak 필요)

**판단 기준:** "이 클로저가 self보다 오래 살아남을 수 있는가?"가 yes면 `[weak self]`.

#### G3.5 Guard로 조기 반환 [Warning]

**규칙:** 사전 조건 검사는 `guard`로 작성합니다. 중첩 if를 피하고 핵심 로직을 하단에 배치합니다.

**Good:**
```swift
func processOrder(_ order: Order) throws {
    guard order.items.isEmpty == false else {
        throw OrderError.empty
    }
    guard order.total > 0 else {
        throw OrderError.invalidTotal
    }
    // 핵심 로직
}
```

**Bad:** 중첩 `if-else`로 사전 조건 검사

---

### G4. 메모리 관리 (ARC)

#### G4.1 클래스 retain cycle 방지 [Error]

**규칙:** 부모-자식 관계에서 자식이 부모를 참조할 때 `weak` 또는 `unowned`를 사용합니다.

**이유:** 양방향 strong reference는 ARC가 해제하지 못해 메모리 누수가 발생합니다.

**Good:**
```swift
class Parent {
    var children: [Child] = []
}
class Child {
    weak var parent: Parent?   // weak로 cycle 차단
}
```

**Bad:**
```swift
class Child {
    var parent: Parent?        // strong → cycle
}
```

#### G4.2 weak vs unowned 선택 [Warning]

**규칙:** 참조 대상이 nil이 될 수 있으면 `weak`(옵셔널), 생명주기가 명확히 부모와 같거나 더 길면 `unowned`를 사용합니다.

**Good:**
- `weak var delegate: SomeDelegate?` (delegate는 해제 가능)
- `unowned let owner: Owner` (owner가 항상 살아있음을 보장)

**Bad:** `unowned`로 선언했지만 대상이 먼저 해제되어 크래시

#### G4.3 delegate는 weak [Error]

**규칙:** Delegate 프로퍼티는 `weak var`로 선언합니다.

**이유:** Delegator가 delegate를 strong하게 잡으면 양방향 cycle이 발생합니다.

**Good:** `weak var delegate: UITableViewDelegate?`
**Bad:** `var delegate: UITableViewDelegate?` (strong)

#### G4.4 NotificationCenter/Timer 정리 [Warning]

**규칙:** `NotificationCenter` 옵저버, `Timer`, KVO는 `deinit`에서 명시적으로 해제합니다 (또는 Combine을 사용).

**Good:**
```swift
class ViewController: UIViewController {
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        observer = NotificationCenter.default.addObserver(
            forName: .userDidLogin, object: nil, queue: .main
        ) { [weak self] _ in self?.refresh() }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }
}
```

---

### G5. 에러 처리

#### G5.1 도메인별 Error enum [Warning]

**규칙:** 도메인별로 `Error`를 채택한 enum을 정의합니다. 일반 `NSError`나 문자열 에러는 피합니다.

**Good:**
```swift
enum NetworkError: Error {
    case timeout
    case invalidResponse(statusCode: Int)
    case decoding(underlying: Error)
}

throw NetworkError.invalidResponse(statusCode: 500)
```

**Bad:**
```swift
throw NSError(domain: "Network", code: 500)
```

#### G5.2 try? / try! 사용 기준 [Error]

**규칙:** `try!`는 사용하지 않습니다. `try?`는 에러 정보가 불필요할 때만 사용합니다.

**이유:** `try!`는 강제 언래핑과 동일하게 크래시를 유발합니다.

**Good:**
```swift
do {
    let data = try fetchData()
    process(data)
} catch let error as NetworkError {
    handleNetworkError(error)
} catch {
    log(error)
}

let cached = try? cache.read(key)   // nil 허용
```

**Bad:** `let data = try! fetchData()`

#### G5.3 LocalizedError 채택 [Info]

**규칙:** 사용자에게 노출되는 에러는 `LocalizedError`를 채택하여 `errorDescription`을 제공합니다.

**Good:**
```swift
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .timeout: return "네트워크 응답 시간을 초과했습니다."
        case .invalidResponse(let code): return "서버 오류 (\(code))"
        case .decoding: return "데이터 형식이 올바르지 않습니다."
        }
    }
}
```

#### G5.4 Result 타입 활용 [Info]

**규칙:** 콜백 기반 비동기 API에서 성공/실패를 모두 다룰 때 `Result<Success, Failure>`를 사용합니다. async/await 가능한 환경에서는 `throws` 함수를 우선합니다.

**Good:**
```swift
func fetchUser(id: String, completion: @escaping (Result<User, NetworkError>) -> Void) { /* ... */ }

// async/await가 가능하면
func fetchUser(id: String) async throws -> User { /* ... */ }
```

#### G5.5 빈 catch 블록 금지 [Error]

**규칙:** 에러를 빈 `catch` 블록으로 무시하지 않습니다. 의도적으로 무시하더라도 최소한 로깅하고 이유를 주석으로 명시합니다.

**이유:** 빈 catch는 디버깅 시 문제 발생 시점을 추적할 수 없게 만들고, 실패가 조용히 누적되는 원인이 됩니다.

**Good:**
```swift
do {
    try cache.write(data)
} catch {
    logger.warning("Cache write failed", error: error)
    // 캐시 쓰기 실패는 critical 아님 — 다음 호출에서 재시도
}
```

**Bad:**
```swift
do { try cache.write(data) } catch { }   // 무엇이 왜 무시되는지 알 수 없음
```

---

### G6. UI 프레임워크 (SwiftUI / UIKit)

#### G6.1 SwiftUI: View body 가벼움 유지 [Warning]

**규칙:** `body` 안에 복잡한 로직을 두지 않습니다. 계산은 computed property나 ViewModel로 분리합니다.

**이유:** `body`는 상태 변경 시 반복 평가되므로 무거운 작업이 성능 저하를 유발합니다.

**Good:**
```swift
struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()

    private var sortedUsers: [User] {
        viewModel.users.sorted { $0.name < $1.name }
    }

    var body: some View {
        List(sortedUsers) { user in
            UserRow(user: user)
        }
    }
}
```

**Bad:** `body` 내부에서 매번 정렬/필터링/네트워크 호출

#### G6.2 SwiftUI: 상태 프로퍼티 래퍼 선택 [Error]

**규칙:** 상태의 소유자와 타깃 OS 버전에 따라 적절한 래퍼를 사용합니다.

**iOS 17+ (권장 — `@Observable` 매크로):**

```swift
@Observable
final class UserViewModel {
    var users: [User] = []
    var isLoading: Bool = false
}
```

| 래퍼 | 용도 |
|------|------|
| `@State` | 뷰 내부 값 타입 상태 + **뷰가 소유하는 `@Observable` 객체** |
| `@Bindable` | `@Observable` 객체에 양방향 바인딩 (`$` 접근) |
| `@Environment` | 환경 주입된 `@Observable` 객체 또는 시스템 값 |
| `@Binding` | 부모 상태에 대한 양방향 바인딩 (값 타입) |

**iOS 16 이하 (레거시 — `ObservableObject`):**

| 래퍼 | 용도 |
|------|------|
| `@State` | 뷰 내부 단순 값 타입 상태 |
| `@StateObject` | 뷰가 **소유**하는 ObservableObject (뷰 생성 시 1회 초기화) |
| `@ObservedObject` | 외부에서 **주입**받는 ObservableObject |
| `@EnvironmentObject` | 환경 주입된 ObservableObject |
| `@Binding` | 부모 상태에 대한 양방향 바인딩 |

**Good (iOS 17+):**
```swift
struct UserListView: View {
    @State private var viewModel = UserViewModel()   // 소유 → @State
    var body: some View { /* ... */ }
}

struct UserEditView: View {
    @Bindable var viewModel: UserViewModel           // 외부 주입 + 바인딩
    var body: some View {
        TextField("Name", text: $viewModel.name)
    }
}
```

**Bad (iOS 16 이하):**
```swift
struct UserListView: View {
    @ObservedObject var viewModel = UserViewModel()   // 재생성됨 → @StateObject 써야 함
}
```

**판단 기준:** iOS 17 이상만 지원하면 `@Observable` 우선, 그 이하 지원이 필요하면 `ObservableObject` 사용. 한 프로젝트에서 두 패턴 혼용은 피하기.

#### G6.3 SwiftUI: List/ForEach에 Identifiable [Warning]

**규칙:** `List`와 `ForEach`에 사용하는 모델은 `Identifiable`을 채택하거나 `id:` 파라미터를 명시합니다.

**이유:** id 없이는 SwiftUI가 diff를 정확히 계산하지 못해 잘못된 애니메이션과 상태 손실이 발생합니다 (UX 결함이지 크래시는 아니므로 [Warning]).

**Good:**
```swift
struct User: Identifiable {
    let id: UUID
    let name: String
}

ForEach(users) { user in UserRow(user: user) }
```

**Bad:** `ForEach(users.indices) { i in UserRow(user: users[i]) }` (인덱스 기반 → 삽입/삭제 시 깨짐)

#### G6.4 비동기는 async/await 우선, UI는 @MainActor [Error]

**규칙:** iOS 13+ (async/await는 iOS 15+ 또는 backport 가능)에서는 콜백/GCD보다 `async/await`을 우선 사용합니다. UI를 갱신하는 ViewModel/Coordinator는 `@MainActor`로 격리합니다.

**이유:** async/await는 콜백 지옥과 retain cycle 위험을 줄이고, `@MainActor`는 컴파일 타임에 메인 스레드 보장을 제공합니다. `DispatchQueue.main.async`로 매번 감싸는 실수와 누락을 컴파일러가 잡아줍니다.

**Good:**
```swift
@MainActor
final class UserViewModel: ObservableObject {
    @Published var users: [User] = []

    func load() async {
        do {
            users = try await userService.fetchAll()   // 자동으로 main에 복귀
        } catch {
            logger.error("Failed", error: error)
        }
    }
}

// 백그라운드 작업이 필요할 때
func process() async throws {
    let raw = try await api.download()
    let parsed = await Task.detached(priority: .userInitiated) {
        try parser.parse(raw)
    }.value
    await MainActor.run { self.update(parsed) }
}
```

**Bad:**
```swift
func load() {
    DispatchQueue.global().async {
        let users = self.fetchSync()
        DispatchQueue.main.async {     // 콜백 지옥, 누락 위험
            self.users = users
        }
    }
}
```

#### G6.5 UIKit: 메인 스레드 UI 업데이트 [Error]

**규칙:** UIKit에서 UI 업데이트는 반드시 메인 스레드에서 수행합니다. 백그라운드 콜백 안에서는 `DispatchQueue.main.async` 또는 `await MainActor.run`을 사용합니다.

**Good:**
```swift
URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
    guard let data, let image = UIImage(data: data) else { return }
    DispatchQueue.main.async {
        self?.imageView.image = image
    }
}.resume()
```

**Bad:** 백그라운드 큐에서 직접 `imageView.image = ...` (런타임 경고/크래시)
**Bad:** `UIImage(data: data ?? Data())` — 빈 Data로 nil 반환되는 의미 없는 호출 (G2 옵셔널 처리 위반)

#### G6.6 UIKit: ViewController 책임 분리 [Warning]

**규칙:** ViewController는 뷰의 생명주기와 라우팅만 담당합니다. 비즈니스 로직, 네트워크, 데이터 변환은 별도 객체(ViewModel/Service)로 분리합니다 (Massive View Controller 안티패턴 회피).

**Good:** ViewController가 ViewModel을 통해 데이터 바인딩, 네트워크는 Service 계층
**Bad:** ViewController에 네트워크 호출, JSON 파싱, 비즈니스 로직이 모두 존재 (1000줄+)

#### G6.7 reuse identifier 상수화 [Warning]

**규칙:** Cell의 reuse identifier를 문자열 리터럴로 흩어 쓰지 않고 타입의 정적 상수로 관리합니다.

**Good:**
```swift
final class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"
}
tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
```

**Bad:** `tableView.dequeueReusableCell(withIdentifier: "userCell")` (대소문자 오타 위험)

#### G6.8 SwiftUI: 뷰는 작게 분리 (컴파일러 타입 추론) [Warning]

**규칙:** SwiftUI 뷰의 `body` 안에서 모디파이어 체인이 길어지거나 분기가 복잡해지면 서브뷰로 분리합니다. 일반적으로 한 뷰의 표현식이 10줄 이상 또는 모디파이어 8개 이상이면 분리 신호입니다.

**이유:** **실무 최대 함정.** SwiftUI는 뷰 트리를 정적 타입으로 표현하기 때문에 표현식이 복잡해지면 컴파일러의 타입 추론이 폭발하여 빌드 타임아웃 또는 `"The compiler is unable to type-check this expression in reasonable time"` 에러가 발생합니다. 분리하면 각 서브뷰의 타입이 독립 추론되어 해결됩니다.

**Good:**
```swift
struct UserProfileView: View {
    let user: User

    var body: some View {
        VStack(spacing: 16) {
            avatarSection
            infoSection
            actionsSection
        }
        .padding()
    }

    private var avatarSection: some View {
        AsyncImage(url: user.avatarURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    }

    private var infoSection: some View { /* ... */ }
    private var actionsSection: some View { /* ... */ }
}
```

**Bad:**
```swift
var body: some View {
    VStack(spacing: 16) {
        AsyncImage(url: user.avatarURL) { image in image.resizable().scaledToFill() }
            placeholder: { ProgressView() }
            .frame(width: 80, height: 80).clipShape(Circle())
        Text(user.name).font(.title).fontWeight(.bold).foregroundColor(.primary)
        Text(user.email).font(.subheadline).foregroundColor(.secondary)
        // ... 모든 게 한 body에 → 컴파일러 타임아웃 위험
    }.padding().background(Color.white).cornerRadius(12).shadow(radius: 4)
}
```

---

## [Verify 모드] 코드 검증 워크플로우

Verify 모드는 지정된 파일/디렉토리의 Swift 코드를 G1-G6 규칙으로 검증하고 보고서를 생성합니다.

> **보고서 작성 규칙:** 위반 항목의 규칙 컬럼은 fully-qualified 형식 `code-convention-ios:G<번호>`을 사용합니다. 예: `code-convention-ios:G2.1`, `code-convention-ios:G4.1`.

### Step 1: 검증 대상 수집

인수로 전달된 파일 경로 또는 glob 패턴을 사용하여 검증 대상 파일을 수집합니다. 인수가 없으면 프로젝트의 Swift 소스 디렉토리 전체를 대상으로 합니다.

Glob 도구를 사용하여 대상 파일을 수집합니다:
- 패턴: `**/*.swift`
- `Pods/`, `.build/`, `DerivedData/`, `Carthage/` 디렉토리는 제외

### Step 2: G1 네이밍 검사

Grep 도구를 사용하여 snake_case 변수/함수를 탐지합니다:
- 패턴: `(let|var|func) [a-z][a-zA-Z0-9]*_[a-z]`
- Glob 필터: `*.swift`
- **면제:** Objective-C 브리지 API (`@objc(snake_case_name)`) 명시적 노출
- **면제:** 외부 JSON 키 매핑 (`CodingKeys` 안의 case)

타입 네이밍 검사:
- 패턴: `(class|struct|enum|protocol) [a-z]` (소문자로 시작하는 타입)

### Step 3: G2 옵셔널/타입 검사

강제 언래핑 탐지:
- 패턴 1: `[a-zA-Z0-9_\)]\!\.` 또는 `[a-zA-Z0-9_\)]\![\s;,\)]` (force unwrap)
- 패턴 2: `as!\s` (force cast)
- 패턴 3: `try!\s` (force try)
- Glob 필터: `*.swift`
- **면제:** `@IBOutlet weak var ...!` 라인 (스토리보드 관례)
- **면제:** 단위 테스트 파일 (`*Tests.swift`, `*Spec.swift`)의 setup 코드
- **면제:** 주석 라인 (`//`, `*`)

### Step 4: G3 함수/클로저 검사

각 파일을 Read로 읽어 다음을 확인:
- 함수 본문이 30줄 초과인지
- escaping closure에서 `self.` 직접 참조 (weak/unowned 캡처 누락 가능성)

Grep으로 escaping closure self 캡처 누락 의심 패턴:
- 패턴: `@escaping.*->.*\{[\s\S]*self\.` (간단 휴리스틱; false positive 가능 → Read로 확인)

### Step 5: G4 메모리 관리 검사

Grep으로 delegate strong 참조 의심:
- 패턴: `^\s*var delegate:` (weak가 빠진 delegate)
- **면제:** protocol 정의 내부의 `var delegate`는 면제

retain cycle 의심 패턴:
- 패턴: `Timer\.scheduledTimer.*\{[^}]*self` (Timer 클로저에서 self 캡처)
- 결과는 [Warning]으로 보고하고 Read로 컨텍스트 확인 권장

### Step 6: G5 에러 처리 검사

Grep으로 위험한 try 사용:
- 패턴: `try!\s`
- 패턴: `\.fatalError\(` (에러 처리 대신 fatalError)

빈 catch 블록:
- 패턴: `catch\s*\{[\s\n]*\}`

### Step 7: G6 UI 프레임워크 검사

SwiftUI 상태 래퍼 오용:
- 패턴: `@ObservedObject\s+var\s+\w+\s*=\s*` (뷰 내부에서 ObservedObject로 객체 생성)
- 결과는 [Error]로 보고 — `@StateObject` 또는 iOS 17+ `@State` + `@Observable`로 교체 필요

UIKit 메인 스레드 의심:
- 패턴: `dataTask.*\{[^}]*\.image\s*=` (백그라운드 콜백에서 UI 직접 업데이트)
- 결과는 [Warning]으로 보고하고 Read로 확인 권장

SwiftUI body 길이 의심 (G6.8):
- Read로 `var body: some View {` 시작부터 매칭되는 `}`까지 줄 수 측정
- 30줄 초과 시 [Warning]으로 보고 — 서브뷰 분리 권장 (컴파일러 타입 추론 폭발 방지)

### Step 8: 보고서 생성

```markdown
## iOS 코드 컨벤션 검증 보고서 (code-convention-ios:G1-G6)
**검증 대상:** <경로> | **검증 일시:** <날짜> | **검증 파일 수:** <N개>

### 요약
| 카테고리 | Error | Warning | Info | 상태 |
|----------|-------|---------|------|------|
| G1 네이밍 | N | N | N | ✅/⚠️/❌ |
| G2 옵셔널/타입 | N | N | N | ✅/⚠️/❌ |
| G3 함수/클로저 | N | N | N | ✅/⚠️/❌ |
| G4 메모리 관리 | N | N | N | ✅/⚠️/❌ |
| G5 에러 처리 | N | N | N | ✅/⚠️/❌ |
| G6 UI 프레임워크 | N | N | N | ✅/⚠️/❌ |
| **합계** | **N** | **N** | **N** | — |

### 상세 위반 목록
| # | 심각도 | 규칙 | 파일 | 라인 | 문제 | 수정 방법 |
|---|--------|------|------|------|------|-----------|

상태 기준: ✅ Error 0 & Warning 0 / ⚠️ Error 0 & Warning 1+ / ❌ Error 1+
```

---

## 예외사항

다음은 **위반이 아닙니다**:

1. **`@IBOutlet`의 `!`** — 스토리보드 연결이 보장되는 관례
2. **단위 테스트의 force unwrap** — 테스트 setup에서 의도적 사용 (실패 시 즉시 알림)
3. **Objective-C 브리지** — `@objc` 네이밍은 ObjC 컨벤션(snake_case 등) 허용
4. **자동 생성 코드** — Xcode 생성 코드, SwiftGen, Sourcery 등 자동 생성물
5. **레거시 코드 점진적 마이그레이션** — 기존 코드 스타일 유지 (새 코드에 규칙 적용)
6. **CodingKeys 매핑** — 외부 JSON 스키마와 매핑 시 snake_case 키 허용

## Related Files

| File | Purpose |
|------|---------|
| `.swiftlint.yml` | SwiftLint 설정 (포매팅 규칙 위임) |
| `.swiftformat` | SwiftFormat 설정 (포매팅 규칙 위임) |
| `Package.swift` / `*.xcodeproj` | 프로젝트 구조 (검증 대상 경로 결정) |
| Apple [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) | 본 스킬의 네이밍/가독성 규칙 출처 |
