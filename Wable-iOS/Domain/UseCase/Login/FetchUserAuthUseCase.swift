//
//  FetchUserAuthUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

final class FetchUserAuthUseCase {
    private let repository: LoginRepository
    
    init(repository: LoginRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchUserAuthUseCase {
    func execute(platform: SocialPlatform) -> AnyPublisher<Account, WableError> {
        return repository.fetchUserAuth(platform: platform, userName: nil)
    }
}
