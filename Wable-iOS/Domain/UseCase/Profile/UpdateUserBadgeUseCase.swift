//
//  UpdateUserBadgeUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/28/25.
//


import Combine

final class UpdateUserBadgeUseCase {
    private let repository: AccountRepository
    
    init(repository: AccountRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension UpdateUserBadgeUseCase {
    func execute(number: Int) -> AnyPublisher<Void, WableError> {
        return repository.updateUserBadge(badge: number)
    }
}

