//
//  FetchUserInformationUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/8/25.
//


import Combine
import Foundation

final class FetchUserInformationUseCase {
    private let repository: UserSessionRepository
    
    init(repository: UserSessionRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchUserInformationUseCase {
    func fetchActiveUserID() -> AnyPublisher<Int?, Never> {
        return Just(repository.fetchActiveUserID())
            .eraseToAnyPublisher()
    }
    
    func fetchActiveUserInfo() -> AnyPublisher<UserSession?, Never> {
        return Just(repository.fetchActiveUserSession())
            .eraseToAnyPublisher()
    }
    
    func updateUserSession(session: UserSession) -> AnyPublisher<Void, Never> {
        return Just(repository.updateUserSession(session))
            .eraseToAnyPublisher()
    }
}
