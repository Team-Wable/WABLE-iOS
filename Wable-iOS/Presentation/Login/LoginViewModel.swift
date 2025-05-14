//
//  LoginViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/23/25.
//


import Combine
import Foundation

final class LoginViewModel {
    
    // MARK: Property
    
    private let updateFCMTokenUseCase: UpdateFCMTokenUseCase
    private let fetchUserAuthUseCase: FetchUserAuthUseCase
    private let updateUserSessionUseCase: FetchUserInformationUseCase
    private let loginSuccessSubject = PassthroughSubject<Account, Never>()
    private let loginErrorSubject = PassthroughSubject<WableError, Never>()
    
    // MARK: - LifeCycle

    init(
        updateFCMTokenUseCase: UpdateFCMTokenUseCase,
        fetchUserAuthUseCase: FetchUserAuthUseCase,
        updateUserSessionUseCase: FetchUserInformationUseCase
    ) {
        self.updateFCMTokenUseCase = updateFCMTokenUseCase
        self.fetchUserAuthUseCase = fetchUserAuthUseCase
        self.updateUserSessionUseCase = updateUserSessionUseCase
    }
}

// MARK: - Extension

extension LoginViewModel: ViewModelType {
    struct Input {
        let kakaoLoginTrigger: AnyPublisher<Void, Never>
        let appleLoginTrigger: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let account: AnyPublisher<Account, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let kakaoLoginTrigger = input.kakaoLoginTrigger
            .map { SocialPlatform.kakao }
        let appleLoginTrigger = input.appleLoginTrigger
            .map { SocialPlatform.apple }
        
        Publishers.Merge(appleLoginTrigger, kakaoLoginTrigger)
            .withUnretained(self)
            .flatMap { owner, flatform -> AnyPublisher<Account, Never> in
                return owner.fetchUserAuthUseCase.execute(platform: flatform)
                    .handleEvents(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            WableLogger.log("로그인 중 오류 발생: \(error)", for: .error)
                        }
                    })
                    .catch { error -> AnyPublisher<Account, Never> in
                        return Empty<Account, Never>().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { completion in
                    WableLogger.log("로그인 작업 완료", for: .debug)
                },
                receiveValue: { [weak self] account in
                    guard let self = self else { return }
                    
                    self.updateFCMTokenUseCase.execute(nickname: account.user.nickname)
                        .sink { completion in
                            if case .failure(let error) = completion {
                                WableLogger.log("FCM 토큰 저장 중 에러 발생: \(error)", for: .error)
                            }
                        } receiveValue: { () in
                        }
                        .store(in: cancelBag)
                    
                    self.updateUserSessionUseCase.updateUserSession(
                        userID: account.user.id,
                        nickname: account.user.nickname,
                        profileURL: account.user.profileURL,
                        isPushAlarmAllowed: account.isPushAlarmAllowed,
                        isAdmin: account.isAdmin,
                        isAutoLoginEnabled: true
                    )
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { _ in
                        WableLogger.log("세션 저장 완료", for: .debug)
                    })
                    .store(in: cancelBag)
                    
                    self.loginSuccessSubject.send(account)
                }
            )
            .store(in: cancelBag)
        
        return Output(
            account: loginSuccessSubject.eraseToAnyPublisher()
        )
    }
}
