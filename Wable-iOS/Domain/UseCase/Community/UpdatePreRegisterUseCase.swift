//
//  UpdatePreRegisterUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

final class UpdatePreRegisterUseCase {
    private let repository: CommunityRepository
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension UpdatePreRegisterUseCase {
    func execute(communityName: LCKTeam) -> AnyPublisher<Void, WableError> {
        return repository.updatePreRegister(communityName: communityName)
            .eraseToAnyPublisher()
    }
}
