![about project](https://github.com/user-attachments/assets/e10fc3b0-1048-4025-ac29-70bd344365d8)
![wable](https://github.com/user-attachments/assets/b02e03eb-6f64-4a44-88e2-88badb3d3b10)

```swift
print("비난, 조롱 없이 내 팀과 선수를 응원하는 커뮤니티")
print("와블 iOS 레포지토리입니다 🚀")
```

<br><br>

![developer](https://github.com/user-attachments/assets/bdbb4bfb-b958-488d-8673-f7280967a23a)

<div align="center">

<table>
  <tr>
    <th>김진웅</br><a href="https://github.com/JinUng41">@JinUng41</a></th>
    <th>이유진</br><a href="https://github.com/youz2me">@youz2me</a></th>
  </tr>
  <tr>
    <td><img width="300" alt="jinung" src="https://github.com/user-attachments/assets/751d0c6b-3885-407e-a9c8-7e97eb93aae7" /></td>
    <td><img width="300" alt="youjin" src="https://github.com/user-attachments/assets/5e9a2c2d-1687-40e5-8b8f-2132338c72b2" /></td>
  </tr>
</table>

</div>

<br><br>

![Git Convention](https://github.com/user-attachments/assets/94c5bb1c-0da8-4f7d-a753-3b245aa58919)

<div align="center">

## Prefix (Tag)

| Prefix   | 설명 |
|----------|------------------------------|
| `Feat`   | 기능 구현 |
| `Add`    | 파일(이미지, 폰트 등 포함) 추가 |
| `Delete` | 파일 삭제 |
| `Chore`  | 짬통 |
| `Refactor` | 코드의 비즈니스 로직 수정 |
| `Fix`    | 버그 등의 기능 전체 수정 |
| `Style`  | UI 스타일(오토레이아웃 등) 설정 |
| `Setting` | 프로젝트 설정 |
| `Docs`   | 문서 작성 |

## Message

> [Prefix] #이슈번호 - 메세지 내용  
> 

```markdown
[Feat] #1 - 로그인 기능 구현
```

</div>

<br><br>

![Coding Convention](https://github.com/user-attachments/assets/14b15313-a25a-4ef9-a76a-0851eb9e55ea)

<details>
<summary><h2> 인터페이스(프로토콜)와 실구현체 </h2></summary>
- 프로토콜의 네이밍: 구현하고자 하는 객체 이름
- 실 구현체의 네이밍: 프로토콜 네이밍 + `Impl`

```swift
protocol UserRepository {}
final class UserRepositoryImpl {} 
```
</details>

<details>
<summary><h2> 함수명 </h2></summary>
  
- 조회: `fetch`
- 수정: `update`
- 삭제: `delete`
- 생성: `create`
- 초기 상태 설정: `configure`
- 액션 메서드: `~DidTap`

</details>

<details>
<summary><h2> UseCase  </h2></summary>
  
- 단일 메서드일 경우, 메서드 명은 `execute`로 한다.
  
</details>

<details>
<summary><h2> Setup Method </h2></summary>

```swift
func setupNavigationBar()
func setupView()
func setupConstraints()
func setupAction()
func setupDelegate()
func setupDataSource()
func setupBinding()
```

</details>

<details>
<summary><h2> MARK 주석 </h2></summary>
- **위, 아래로 한 줄 씩 공백**을 두고 작성합니다.

```swift
// MARK: - Property
// MARK: - Initializer
// MARK: - Life Cycle
// MARK: - Setup Method
// MARK: - UICollectionViewDelegate (ex)
// MARK: - Private Method
```

</details>

<details>
<summary><h2> Mapper </h2></summary>

> DTO → Entity
> 
- `enum`의 `static` method로 구현
- 메서드 네이밍: `map(with dto:)`

</details>

<details>
<summary><h2> 라이브러리 선언 </h2></summary>
  
- 퍼스트 파티와 서드 파티를 분리
- 순서는 무조건 알파벳순

```swift
import Combine
import Foundation

import CombineMoya
import Moya
```
</details>

<details>
<summary><h2> 반복되는 숫자, 문자열 등 선언 </h2></summary>
  
- 객체에서 반복되는 숫자, 문자열 등에 대해서 중첩 타입으로 Constant를 정의하고 타입 프로퍼티로 선언한다.

```swift
final class CustomView: UIView {}

// MARK: - Constant

private extension CustomView {
	enum Constant {
		static let padding: CGFloat = 16
	}
}
```

</details>

<br><br>

