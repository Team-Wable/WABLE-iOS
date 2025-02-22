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
}
