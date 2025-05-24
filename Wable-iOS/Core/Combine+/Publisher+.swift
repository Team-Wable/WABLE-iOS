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
    
    /// `self`가 새로운 값을 방출할 때마다 `other` Publisher가 가장 마지막으로 방출한 값을 함께 전달하는 연산자입니다.
    ///
    /// 이 메서드는 `self`의 이벤트를 트리거로 사용하며, 해당 시점에서 `other`의 최신 값을 가져와 방출합니다.
    ///
    /// - Parameters:
    ///   - other: 참조할 다른 `Publisher`. 이 Publisher가 방출한 마지막 값이 `self`의 트리거에 따라 전달됩니다.
    ///
    /// - Returns: `self`의 방출 이벤트를 트리거로 하여 `other`의 최신 값을 방출하는 `AnyPublisher`.
    ///
    /// - 사용 예:
    ///   ```
    ///   buttonTapPublisher
    ///       .withLatestFrom(textFieldTextPublisher)
    ///       .sink { latestText in
    ///           print("버튼 탭 시 최신 텍스트: \(latestText)")
    ///       }
    ///   ```
    ///
    /// - Note: `other`가 값을 방출하지 않은 상태에서는 `self`가 아무리 값을 방출하더라도 출력이 발생하지 않습니다.
    ///   반드시 `other`가 최소 한 번은 값을 내보낸 이후여야 `withLatestFrom`이 동작합니다.
    ///   이 동작은 RxSwift의 `withLatestFrom`과 동일한 특성을 가집니다.
    ///
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
}
