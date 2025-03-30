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
    private let tokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    
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
                do {
                    try self.tokenStorage.save(account.token.accessToken, for: .wableAccessToken)
                    
                    WableLogger.log("액세스 토큰 저장 성공: \(account.token.accessToken)", for: .debug)
                    try self.tokenStorage.save(account.token.refreshToken, for: .wableRefreshToken)
                    
                    WableLogger.log("리프레시 토큰 저장 성공: \(account.token.refreshToken)", for: .debug)
                } catch {
                    WableLogger.log("토큰 저장 실패: \(error)", for: .debug)
                }
                
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
                
                self.userSessionRepository.updateActiveUserID(account.user.id)
            })
            .eraseToAnyPublisher()
    }
}
