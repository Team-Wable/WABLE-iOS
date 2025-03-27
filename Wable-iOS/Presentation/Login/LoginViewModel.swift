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
        input.kakaoLoginTrigger
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Account, WableError> in
                return owner.fetchUserAuthUseCase.execute(platform: .kakao)
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.loginErrorSubject.send(error)
                    }
                },
                receiveValue: { [weak self] account in
                    self?.loginSuccessSubject.send(account)
                }
            )
            .store(in: cancelBag)
        
        input.appleLoginTrigger
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Account, WableError> in
                return owner.fetchUserAuthUseCase.execute(platform: .apple)
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.loginErrorSubject.send(error)
                    }
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
