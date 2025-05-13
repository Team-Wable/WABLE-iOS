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
        guard let activeUserSession = repository.fetchActiveUserSession() else {
            return nil
        }
        
        if activeUserSession.id == userID { return .owner }
        
        if activeUserSession.isAdmin { return .admin }
        
        return .viewer
    }
}
