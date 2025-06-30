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
    
    private let userProfileUseCase: UserProfileUseCase
    private let fetchUserAuthUseCase: FetchUserAuthUseCase
    private let updateFCMTokenUseCase: UpdateFCMTokenUseCase
    private let updateUserSessionUseCase: FetchUserInformationUseCase
    private let loginErrorSubject = PassthroughSubject<WableError, Never>()
    private let loginSuccessSubject = PassthroughSubject<Account, Never>()
    
    // MARK: - Life Cycle

    init(
        userProfileUseCase: UserProfileUseCase,
        fetchUserAuthUseCase: FetchUserAuthUseCase,
        updateFCMTokenUseCase: UpdateFCMTokenUseCase,
        updateUserSessionUseCase: FetchUserInformationUseCase
    ) {
        self.userProfileUseCase = userProfileUseCase
        self.fetchUserAuthUseCase = fetchUserAuthUseCase
        self.updateFCMTokenUseCase = updateFCMTokenUseCase
        self.updateUserSessionUseCase = updateUserSessionUseCase
    }
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
        return fetchUserAuthUseCase.execute(platform: platform)
            .handleEvents(receiveCompletion: { completion in
                if case .failure(let error) = completion { self.loginErrorSubject.send(error) }
            })
            .catch { error -> AnyPublisher<Account, Never> in
                return Empty<Account, Never>().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func updateFCMToken(account: Account, cancelBag: CancelBag) {
        self.updateFCMTokenUseCase.execute(nickname: account.user.nickname)
            .catch { error -> AnyPublisher<Void, Never> in
                self.loginErrorSubject.send(error)
                return .just(())
            }
            .sink(receiveValue: {})
            .store(in: cancelBag)
    }
    
    func updateUserProfile(userID: Int, cancelBag: CancelBag) {
        Task {
            let authorizedStatus = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            let isAuthorized = authorizedStatus == .authorized
            
            self.userProfileUseCase.updateProfile(userID: userID, isPushAlarmAllowed: isAuthorized)
                .catch { error -> AnyPublisher<Void, Never> in
                    self.loginErrorSubject.send(error)
                    return .just(())
                }
                .sink(receiveValue: {})
                .store(in: cancelBag)
        }
    }
}
