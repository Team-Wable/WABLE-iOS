//
//  UpdateFCMTokenUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 5/14/25.
//


import Combine

final class UpdateFCMTokenUseCase {
    private let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension UpdateFCMTokenUseCase {
    func execute(nickname: String) -> AnyPublisher<Void, WableError> {
        guard let token = repository.fetchFCMToken() else {
            return .fail(WableError.noToken)
        }
        
        return repository.updateUserProfile(nickname: nickname, fcmToken: token)
    }
}

