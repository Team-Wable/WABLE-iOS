//
//  FetchKakaoAuthUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

final class FetchKakaoAuthUseCase {
    private let repository: LoginRepository
    
    init(repository: LoginRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchKakaoAuthUseCase {
    func execute() -> AnyPublisher<Account, WableError> {
        return repository.fetchKakaoAuth()
            .flatMap {
                self.repository.fetchUserAuth(
                    platform: SocialPlatform.kakao.rawValue,
                    userName: nil
                )
            }
            .eraseToAnyPublisher()
    }
}
