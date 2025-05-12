//
//  CheckUserRoleUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Foundation

protocol CheckUserRoleUseCase {
    func execute(userID: Int) -> UserRole?
}

final class CheckUserRoleUseCaseImpl: CheckUserRoleUseCase {
    private let repository: UserSessionRepository
    
    init(repository: UserSessionRepository) {
        self.repository = repository
    }
    
    func execute(userID: Int) -> UserRole? {
        guard let userSession = repository.fetchUserSession(forUserID: userID) else {
            return nil
        }
        
        if userSession.id == userID { return .owner }
        
        if userSession.isAdmin { return .admin }
        
        return .viewer
    }
}
