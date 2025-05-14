//
//  FetchUserProfileUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol FetchUserProfileUseCase {
    func execute(userID: Int) -> AnyPublisher<UserProfile?, WableError>
}

final class FetchUserProfileUseCaseImpl: FetchUserProfileUseCase {
    private let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
    
    func execute(userID: Int) -> AnyPublisher<UserProfile?, WableError> {
        guard userID > .zero else {
            return .fail(.notFoundMember)
        }
        
        return repository.fetchUserProfile(memberID: userID)
            .map { $0 }
            .eraseToAnyPublisher()
    }
}
