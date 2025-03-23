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
        let loginSuccess: AnyPublisher<Account, Never>
        /// 이후 로그인 실패 시 에러 추가될 것을 고려해 추가해둠
        let loginError: AnyPublisher<WableError, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        input.kakaoLoginTrigger
            .flatMap { _ -> AnyPublisher<Account, WableError> in
                return self.fetchUserAuthUseCase.execute(platform: .kakao)
            }
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.loginErrorSubject.send(error)
                    }
                },
                receiveValue: { account in
                    self.loginSuccessSubject.send(account)
                }
            )
            .store(in: cancelBag)
        
        input.appleLoginTrigger
            .flatMap { _ -> AnyPublisher<Account, WableError> in
                return self.fetchUserAuthUseCase.execute(platform: .apple)
            }
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.loginErrorSubject.send(error)
                    }
                },
                receiveValue: { account in
                    self.loginSuccessSubject.send(account)
                }
            )
            .store(in: cancelBag)
        
        return Output(
            loginSuccess: loginSuccessSubject.eraseToAnyPublisher(),
            loginError: loginErrorSubject.eraseToAnyPublisher()
        )
    }
}
