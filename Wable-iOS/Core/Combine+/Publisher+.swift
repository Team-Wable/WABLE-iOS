//
//  Publisher+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/13/25.
//

import Combine
import Foundation

extension Publisher {
    
    // MARK: - withUnretained

    /// 이 메서드는 클로저 내부에서 `owner`를 약한 참조(`weak`)로 캡처하여
    /// 메모리 순환 참조를 방지하고, `owner`가 존재하지 않을 경우 값을 무시합니다.
    ///
    /// - Parameters:
    ///   - owner: `AnyObject` 타입의 소유 객체로, 주로 뷰 컨트롤러와 같은 객체를 전달합니다.
    ///
    /// - Returns: 소유 객체(`owner`)와 Publisher의 Output 값을 튜플로 반환하는 `AnyPublisher`.
    ///   만약 `owner`가 메모리에서 해제되었다면 해당 값은 무시되고, 이벤트는 발생하지 않습니다.
    ///
    /// - 사용 예:
    ///   ```
    ///   myPublisher
    ///       .withUnretained(self)
    ///       .sink { owner, value in
    ///           // `owner`는 안전하게 접근 가능하며, 해제되었을 경우 이벤트가 전달되지 않습니다.
    ///           print("\(owner)의 값: \(value)")
    ///       }
    ///   ```
    ///
    func withUnretained<Object: AnyObject>(_ owner: Object) -> AnyPublisher<(Object, Output), Failure> {
        self.compactMap { [weak owner] value in
            guard let owner else { return nil }
            return (owner, value)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - asVoid
    
    func asVoid() -> AnyPublisher<Void, Failure> {
        self.map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - normalizeError
    
    func normalizeError() -> AnyPublisher<Output, Error> {
        self.mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    // MARK: - asVoidWithError

    func asVoidWithError() -> AnyPublisher<Void, Error> {
        self.map { _ in () }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    // MARK: - withLatestFrom
    
    /// `self`가 새로운 값을 방출할 때마다 `other`의 최신 값을 함께 방출하는 연산자입니다.
    ///
    /// 이 메서드는 `self`의 이벤트를 트리거로 사용하며, 해당 시점에서 `other`가 가장 마지막으로 방출한 값을 함께 전달합니다.
    ///
    /// - Parameters:
    ///   - other: 참조할 다른 `Publisher`.
    ///
    /// - Returns: `self`가 방출될 때 `other`의 최신 값을 방출하는 `AnyPublisher`.
    ///
    /// - Note:
    ///   `other`가 값을 한 번도 방출하지 않은 경우에는 `self`가 값을 방출하더라도 출력이 발생하지 않습니다.
    ///
    /// - Example:
    ///   ```swift
    ///   buttonTapPublisher
    ///       .withLatestFrom(textFieldTextPublisher)
    ///       .sink { latestText in
    ///           print("버튼 탭 시 최신 텍스트: \(latestText)")
    ///       }
    ///   ```
    func withLatestFrom<Other: Publisher>(
        _ other: Other
    ) -> AnyPublisher<Other.Output, Failure> where Other.Failure == Failure {
        self
            .map { _ in Date.now.timeIntervalSince1970 }
            .combineLatest(other)
            .removeDuplicates(by: { $0.0 == $1.0 })
            .map { $0.1 }
            .eraseToAnyPublisher()
    }
    
    /// `self`가 새로운 값을 방출할 때마다 `other`의 최신 값을 함께 사용하여 가공된 값을 방출하는 연산자입니다.
    ///
    /// - Parameters:
    ///   - other: 참조할 다른 `Publisher`.
    ///   - resultSelector: `self`와 `other`의 값을 받아 원하는 형태로 가공하는 클로저.
    ///
    /// - Returns: `self`의 이벤트를 트리거로 하여, `other`의 최신 값과 함께 가공한 결과를 방출하는 `AnyPublisher`.
    ///
    /// - Note:
    ///   `other`가 값을 한 번도 방출하지 않은 경우에는 출력이 발생하지 않습니다.
    ///
    /// - Example:
    ///   ```swift
    ///   buttonTapPublisher
    ///       .withLatestFrom(textFieldTextPublisher) { _, text in
    ///           return "입력된 텍스트: \(text)"
    ///       }
    ///       .sink { result in
    ///           print(result)
    ///       }
    ///   ```
    func withLatestFrom<Other: Publisher, Result>(
        _ other: Other,
        _ resultSelector: @escaping (Output, Other.Output) -> Result
    ) -> AnyPublisher<Result, Failure> where Other.Failure == Failure {
        self
            .map { ($0, Date.now.timeIntervalSince1970) }
            .combineLatest(other)
            .removeDuplicates { $0.0.1 == $1.0.1 }
            .map { lhs, rhs in resultSelector(lhs.0, rhs) }
            .eraseToAnyPublisher()
    }
    
    /// `self`가 새로운 값을 방출할 때마다 `other1`, `other2`의 최신 값을 함께 방출하는 연산자입니다.
    ///
    /// - Parameters:
    ///   - other1: 첫 번째 참조할 `Publisher`.
    ///   - other2: 두 번째 참조할 `Publisher`.
    ///
    /// - Returns: `self`가 방출될 때 `other1`, `other2`의 최신 값을 튜플 형태로 방출하는 `AnyPublisher`.
    ///
    /// - Note:
    ///   두 퍼블리셔 모두 최소 한 번 이상 값을 방출해야 출력이 발생합니다.
    ///
    /// - Example:
    ///   ```swift
    ///   buttonTapPublisher
    ///       .withLatestFrom(textPublisher, togglePublisher)
    ///       .sink { text, isOn in
    ///           print("텍스트: \(text), 스위치: \(isOn)")
    ///       }
    ///   ```
    func withLatestFrom<Other1: Publisher, Other2: Publisher>(
        _ other1: Other1,
        _ other2: Other2
    ) -> AnyPublisher<(Other1.Output, Other2.Output), Failure> where Other1.Failure == Failure, Other2.Failure == Failure {
        self
            .map { _ in Date.now.timeIntervalSince1970 }
            .combineLatest(other1, other2)
            .removeDuplicates { $0.0 == $1.0 }
            .map { ($0.1, $0.2) }
            .eraseToAnyPublisher()
    }
    
    /// `self`가 새로운 값을 방출할 때마다 `other1`, `other2`의 최신 값을 함께 사용하여 가공된 값을 방출하는 연산자입니다.
    ///
    /// - Parameters:
    ///   - other1: 첫 번째 참조할 `Publisher`.
    ///   - other2: 두 번째 참조할 `Publisher`.
    ///   - resultSelector: `self`, `other1`, `other2`의 값을 받아 원하는 형태로 가공하는 클로저.
    ///
    /// - Returns: `self`의 이벤트를 트리거로 하여, 두 퍼블리셔의 최신 값을 함께 사용한 결과를 방출하는 `AnyPublisher`.
    ///
    /// - Note:
    ///   두 퍼블리셔 모두 최소 한 번 이상 값을 방출해야 출력이 발생합니다.
    ///
    /// - Example:
    ///   ```swift
    ///   buttonTapPublisher
    ///       .withLatestFrom(textPublisher, togglePublisher) { _, text, isOn in
    ///           return "입력: \(text), 상태: \(isOn)"
    ///       }
    ///       .sink { result in
    ///           print(result)
    ///       }
    ///   ```
    func withLatestFrom<Other1: Publisher, Other2: Publisher, Result>(
        _ other1: Other1,
        _ other2: Other2,
        _ resultSelector: @escaping (Output, Other1.Output, Other2.Output) -> Result
    ) -> AnyPublisher<Result, Failure>
    where Other1.Failure == Failure, Other2.Failure == Failure {
        self
            .map { ($0, Date.now.timeIntervalSince1970) }
            .combineLatest(other1, other2)
            .removeDuplicates { $0.0.1 == $1.0.1 }
            .map { trigger, value1, value2 in
                resultSelector(trigger.0, value1, value2)
            }
            .eraseToAnyPublisher()
    }
}
