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
    
    func updateUserSession(
        userID: Int,
        nickname: String? = nil,
        profileURL: URL? = nil,
        isPushAlarmAllowed: Bool? = nil,
        isAdmin: Bool? = nil,
        isAutoLoginEnabled: Bool? = nil,
        notificationBadgeCount: Int? = nil
    ) -> AnyPublisher<Void, Never> {
        return Just(
            repository.updateUserSession(
                userID: userID,
                nickname: nickname,
                profileURL: profileURL,
                isPushAlarmAllowed: isPushAlarmAllowed,
                isAdmin: isAdmin,
                isAutoLoginEnabled: isAutoLoginEnabled,
                notificationBadgeCount: notificationBadgeCount
            )
        )
        .eraseToAnyPublisher()
    }
}
