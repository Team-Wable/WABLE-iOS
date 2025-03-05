//
//  FetchAppleAuthUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

final class FetchAppleAuthUseCase {
    private let repository: LoginRepository
    
    init(repository: LoginRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchAppleAuthUseCase {
    func execute() -> AnyPublisher<Account, WableError> {
        return repository.fetchAppleAuth()
            .flatMap { name in
                self.repository.fetchUserAuth(
                    platform: SocialPlatform.apple.rawValue,
                    userName: name
                )
            }
            .eraseToAnyPublisher()
    }
}
