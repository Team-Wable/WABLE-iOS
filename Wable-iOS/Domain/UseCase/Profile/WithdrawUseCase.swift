//
//  WithdrawUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol WithdrawUseCase {
    func execute(reasons: [WithdrawalReason]) -> AnyPublisher<Void, WableError>
}

final class WithdrawUseCaseImpl: WithdrawUseCase {
    @Injected private var accountRepository: AccountRepository
    @Injected private var userSessionRepository: UserSessionRepository
    @Injected private var userActivityRepository: UserActivityRepository
    
    func execute(reasons: [WithdrawalReason]) -> AnyPublisher<Void, WableError> {        
        return accountRepository.deleteAccount(reason: reasons.map(\.rawValue))
            .append(removeUserActivity())
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .finished = completion {
                    self?.removeUserSession()
                }
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - Helper Method

private extension WithdrawUseCaseImpl {
    func removeUserActivity() -> AnyPublisher<Void, WableError> {
        guard let userID = userSessionRepository.fetchActiveUserID(),
              let validUserID = UInt(exactly: userID)
        else {
            return .fail(.invalidMember)
        }

        return userActivityRepository.removeUserActivity(for: validUserID)
    }

    func removeUserSession() {
        guard let userID = userSessionRepository.fetchActiveUserID() else {
            return WableLogger.log("유저 아이디를 찾을 수 없음.", for: .debug)
        }
        
        userSessionRepository.removeUserSession(forUserID: userID)
    }   
}
