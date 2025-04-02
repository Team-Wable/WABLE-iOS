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

    private let fetchUserAuthUseCase: FetchUserAuthUseCase
    private let loginSuccessSubject = PassthroughSubject<Account, Never>()
    private let loginErrorSubject = PassthroughSubject<WableError, Never>()
    
    // MARK: - LifeCycle

    init(useCase: FetchUserAuthUseCase) {
        self.fetchUserAuthUseCase = useCase
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
                    self?.loginSuccessSubject.send(account)
                }
            )
            .store(in: cancelBag)
        
        return Output(
            account: loginSuccessSubject.eraseToAnyPublisher()
        )
    }
}
