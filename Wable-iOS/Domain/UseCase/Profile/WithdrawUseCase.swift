//
//  WithdrawUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol WithdrawUseCase {
    func execute(reasons: [WithdrawalReason]) -> AnyPublisher<Bool, WableError>
}

final class WithdrawUseCaseImpl: WithdrawUseCase {
    private let repository: AccountRepository
    
    init(repository: AccountRepository) {
        self.repository = repository
    }
    
    func execute(reasons: [WithdrawalReason]) -> AnyPublisher<Bool, WableError> {
        return repository.deleteAccount(reason: reasons.map { $0.rawValue })
            .map { _ in true }
            .eraseToAnyPublisher()
    }
}
