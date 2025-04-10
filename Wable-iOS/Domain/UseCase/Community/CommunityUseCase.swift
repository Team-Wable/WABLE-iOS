//
//  CommunityUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Combine
import Foundation

protocol CommunityUseCase {
    func isUserRegistered() -> AnyPublisher<CommunityRegistrationStatus, WableError>
    func fetchCommunityList() -> AnyPublisher<[Community], WableError>
    func register(for communityTeam: LCKTeam) -> AnyPublisher<Double, WableError>
}

final class CommunityUseCaseImpl: CommunityUseCase {
    private let repository: CommunityRepository
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
    
    func isUserRegistered() -> AnyPublisher<CommunityRegistrationStatus, WableError> {
        return repository.isUserRegistered()
    }
    
    func fetchCommunityList() -> AnyPublisher<[Community], WableError> {
        return repository.fetchCommunityList()
    }
    
    func register(for communityTeam: LCKTeam) -> AnyPublisher<Double, WableError> {
        return repository.updateRegister(communityName: communityTeam.rawValue)
    }
}
