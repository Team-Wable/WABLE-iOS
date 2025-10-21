//
//  AnyPublisher+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/13/25.
//

import Combine
import Foundation

extension AnyPublisher {
    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        return Just(output)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
    
    static func fail(_ failure: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: failure)
            .eraseToAnyPublisher()
    }

    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty()
            .eraseToAnyPublisher()
    }
}
