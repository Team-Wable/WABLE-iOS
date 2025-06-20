//
//  FetchUserProfileUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol FetchUserProfileUseCase {
    func execute(userID: Int) async throws -> UserProfile
}

final class FetchUserProfileUseCaseImpl: FetchUserProfileUseCase {
    @Injected private var repository: ProfileRepository
    
    func execute(userID: Int) async throws -> UserProfile {
        if userID <= .zero {
            throw WableError.notFoundMember
        }
        
        return try await repository.fetchUserProfile(memberID: userID)
    }
}
