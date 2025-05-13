//
//  ErrorMapper.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/25/25.
//


import Combine
import Foundation

extension Publisher where Failure == NetworkError {
    func mapWableError() -> AnyPublisher<Output, WableError> {
        self.mapError { error in
            WableLogger.log(error.localizedDescription, for: .network)
            WableLogger.log("\(error)", for: .network)
            switch error {
            case .statusError(_, let message):
                return WableError(rawValue: message) ?? .networkError
            default:
                return WableError.unknownError
            }
        }
        .eraseToAnyPublisher()
    }
}
