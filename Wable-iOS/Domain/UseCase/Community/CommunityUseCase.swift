//
//  CommunityUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Combine
import Foundation

protocol CommunityUseCase {
    func fetchCommunityList() -> AnyPublisher<[Community], WableError>
    func preRegister(communityName: String) -> AnyPublisher<Double, WableError>
    func isUserPreRegistered() -> AnyPublisher<CommunityPreRegistrationStatus, WableError>
}

final class CommunityUseCaseImpl: CommunityUseCase {
    private let repository: CommunityRepository
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
    
    func fetchCommunityList() -> AnyPublisher<[Community], WableError> {
        return repository.fetchCommunityList()
    }
    
    func preRegister(communityName: String) -> AnyPublisher<Double, WableError> {
        return repository.updatePreRegister(communityName: communityName)
    }
    
    func isUserPreRegistered() -> AnyPublisher<CommunityPreRegistrationStatus, WableError> {
        return repository.isUserPreRegistered()
            .map { name -> CommunityPreRegistrationStatus in
                guard let name else {
                    return .notPreRegistered
                }
                return .preRegistered(communityName: name)
            }
            .eraseToAnyPublisher()
    }
}
