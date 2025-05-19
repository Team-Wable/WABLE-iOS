//
//  RemoveUserSessionUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Foundation

protocol RemoveUserSessionUseCase {
    func removeUserSession()
}

final class RemoveUserSessionUseCaseImpl: RemoveUserSessionUseCase {
    private let repository: UserSessionRepository
    
    init(repository: UserSessionRepository) {
        self.repository = repository
    }
    
    func removeUserSession() {
        guard let userID = repository.fetchActiveUserID() else {
            WableLogger.log("유저 아이디를 찾을 수 없음.", for: .debug)
            return
        }
        
        repository.removeUserSession(forUserID: userID)
    }
}
