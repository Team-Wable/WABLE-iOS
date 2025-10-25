//
//  LoginViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/23/25.
//


import Combine
import Foundation
import UserNotifications

final class LoginViewModel {
    
    // MARK: Property
    
    private let loginSuccessSubject = PassthroughSubject<Account, Never>()
    private let loginErrorSubject = PassthroughSubject<WableError, Never>()
    
    @Injected private var tokenStorage: TokenStorage
    @Injected private var loginRepository: LoginRepository
    @Injected private var profileRepository: ProfileRepository
    @Injected private var userSessionRepository: UserSessionRepository
}

extension LoginViewModel: ViewModelType {
    struct Input {
        let kakaoLoginTrigger: AnyPublisher<Void, Never>
        let appleLoginTrigger: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let error: AnyPublisher<WableError, Never>
        let account: AnyPublisher<Account, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let kakaoLoginTrigger = input.kakaoLoginTrigger.map { SocialPlatform.kakao }
        let appleLoginTrigger = input.appleLoginTrigger.map { SocialPlatform.apple }
        
        Publishers.Merge(appleLoginTrigger, kakaoLoginTrigger)
            .withUnretained(self)
            .flatMap { owner, platform -> AnyPublisher<Account, Never> in
                return owner.fetchUserAuth(platform: platform)
            }
            .sink(receiveValue: { [weak self] account in
                guard let self = self else { return }
                
                self.updateFCMToken(account: account, cancelBag: cancelBag)
                self.updateUserProfile(userID: account.user.id, cancelBag: cancelBag)
                self.loginSuccessSubject.send(account)
            })
            .store(in: cancelBag)
        
        return Output(
            error: loginErrorSubject.eraseToAnyPublisher(),
            account: loginSuccessSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension LoginViewModel {
    func fetchUserAuth(platform: SocialPlatform) -> AnyPublisher<Account, Never> {
        return loginRepository.fetchUserAuth(platform: platform, userName: nil)
            .handleEvents(receiveOutput: { [weak self] account in
                guard let self = self else { return }
                
                self.updateToken(accessToken: account.token.accessToken, refreshToken: account.token.refreshToken)
                self.updateUserSession(account: account)
            })
            .catch { [weak self] error -> AnyPublisher<Account, Never> in
                self?.loginErrorSubject.send(error)
                return Empty<Account, Never>().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func updateToken(accessToken: String, refreshToken: String) {
        do {
            try self.tokenStorage.save(accessToken, for: .wableAccessToken)
            try self.tokenStorage.save(refreshToken, for: .wableRefreshToken)
        } catch let error as WableError {
            loginErrorSubject.send(error)
        } catch {
            loginErrorSubject.send(.unknownError)
        }
    }
    
    func updateUserSession(account: Account) {
        let existingSession = userSessionRepository.fetchUserSession(forUserID: account.user.id)

        userSessionRepository.updateUserSession(
            userID: account.user.id,
            nickname: account.user.nickname,
            profileURL: account.user.profileURL,
            isPushAlarmAllowed: account.isPushAlarmAllowed ?? false,
            isAdmin: account.isAdmin,
            isAutoLoginEnabled: true,
            notificationBadgeCount: nil,
            quizCompletedAt: existingSession?.quizCompletedAt
        )
        
        userSessionRepository.updateActiveUserID(account.user.id)
    }
    
    func updateFCMToken(account: Account, cancelBag: CancelBag) {
        guard let token = profileRepository.fetchFCMToken() else { return }
        
        profileRepository.updateUserProfile(nickname: account.user.nickname, fcmToken: token)
            .catch { [weak self] error -> AnyPublisher<Void, Never> in
                self?.loginErrorSubject.send(error)
                return .just(())
            }
            .sink(receiveValue: {})
            .store(in: cancelBag)
    }
    
    func updateUserProfile(userID: Int, cancelBag: CancelBag) {
        Task {
            let authorizedStatus = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            let isAuthorized = authorizedStatus == .authorized
            let profile = try await profileRepository.fetchUserProfile(memberID: userID)
            
            profileRepository.updateUserProfile(
                profile: profile,
                isPushAlarmAllowed: isAuthorized,
                isAlarmAllowed: nil,
                image: nil,
                fcmToken: nil,
                defaultProfileType: nil
            )
            .catch { [weak self] error -> AnyPublisher<Void, Never> in
                self?.loginErrorSubject.send(error)
                return .just(())
            }
            .sink(receiveValue: {})
            .store(in: cancelBag)
        }
    }
}
