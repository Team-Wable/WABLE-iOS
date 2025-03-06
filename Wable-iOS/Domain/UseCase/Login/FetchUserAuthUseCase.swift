//
//  FetchUserAuthUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

final class FetchUserAuthUseCase {
    private let loginRepository: LoginRepository
    private let userSessionRepository: UserSessionRepository
    
    init(loginRepository: LoginRepository, userSessionRepository: UserSessionRepository) {
        self.loginRepository = loginRepository
        self.userSessionRepository = userSessionRepository
    }
}

// MARK: - Extension

extension FetchUserAuthUseCase {
    func execute(platform: SocialPlatform) -> AnyPublisher<Account, WableError> {
        return loginRepository.fetchUserAuth(platform: platform, userName: nil)
            .handleEvents(receiveOutput: { account in
                self.userSessionRepository.updateAutoLogin(
                    enabled: true,
                    forUserID: account.user.id
                )
                
                self.userSessionRepository.updateUserSession(
                    UserSession(
                        id: account.user.id,
                        nickname: account.user.nickname,
                        profileURL: account.user.profileURL?.absoluteString ?? "",
                        isPushAlarmAllowed: account.isPushAlarmAllowed ?? false,
                        isAdmin: account.isAdmin,
                        isAutoLoginEnabled: true,
                        notificationBadgeCount: 0
                    ),
                    forUserID: account.user.id
                )
                
                self.userSessionRepository.updateActiveUserID(forUserID: account.user.id)
            })
            .eraseToAnyPublisher()
    }
}
