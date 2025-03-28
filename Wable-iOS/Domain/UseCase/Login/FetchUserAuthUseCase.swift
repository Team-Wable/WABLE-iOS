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
    /// Executes the user authentication process for the specified social platform.
    /// 
    /// Initiates an authentication request using the login repository. Upon receiving an authenticated account,
    /// the method attempts to save the access and refresh tokens securely. It logs success or failure for both token
    /// storage operations and then updates the user session repository with the account's session details, including 
    /// user identification and related preferences. The resulting publisher emits an `Account` on success or a `WableError` on failure.
    /// 
    /// - Parameter platform: The social platform to use for authentication.
    /// - Returns: A publisher that emits an authenticated `Account` or a `WableError`.
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
