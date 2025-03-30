//
//  Publisher+Driver.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/30/25.
//

import Combine
import Foundation

extension Publisher {
    func asDriver(onErrorJustReturn defaultValue: Output) -> Driver<Output> {
        return self
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {
    func asDriver() -> Driver<Output> {
        return self
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
