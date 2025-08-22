//
//  Publisher+Driver.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/30/25.
//

import Combine
import Foundation

extension Publisher {
    /**
     * Publisher를 Driver로 변환합니다.
     *
     * - 모든 에러를 주어진 기본값으로 대체합니다.
     * - 메인 스레드에서 결과를 전달합니다.
     * - AnyPublisher로 타입을 지웁니다.
     *
     * - Parameter defaultValue: 에러 발생 시 대체할 기본값
     * - Returns: 메인 스레드에서 동작하고 에러가 없는 Driver<Output>
     */
    func asDriver(onErrorJustReturn defaultValue: Output) -> Driver<Output> {
        return self
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {
    /**
     * 에러가 없는 Publisher를 Driver로 변환합니다.
     *
     * - 메인 스레드에서 결과를 전달합니다.
     * - AnyPublisher로 타입을 지웁니다.
     *
     * - Returns: 메인 스레드에서 동작하는 Driver<Output>
     */
    func asDriver() -> Driver<Output> {
        return self
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
