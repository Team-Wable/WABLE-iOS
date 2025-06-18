//
//  CommunityUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Combine
import Foundation

protocol CommunityUseCase {
    func isUserRegistered() -> AnyPublisher<CommunityRegistration, WableError>
    func fetchCommunityList() -> AnyPublisher<[Community], WableError>
    func register(for communityTeam: LCKTeam) -> AnyPublisher<Double, WableError>
}

final class CommunityUseCaseImpl: CommunityUseCase {
    private let repository: CommunityRepository
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
    
    func isUserRegistered() -> AnyPublisher<CommunityRegistration, WableError> {
        return repository.isUserRegistered()
    }
    
    func fetchCommunityList() -> AnyPublisher<[Community], WableError> {
        return repository.fetchCommunityList()
    }
    
    func register(for communityTeam: LCKTeam) -> AnyPublisher<Double, WableError> {
        return repository.updateRegister(communityName: communityTeam.rawValue)
    }
}

final class MockCommunityUseCaseImpl: CommunityUseCase {
    private var randomDelay: TimeInterval { Double.random(in: 0.7...1.3) }
    
    func isUserRegistered() -> AnyPublisher<CommunityRegistration, WableError> {
        let registration = CommunityRegistration(team: nil, hasRegisteredTeam: false)
        return .just(registration)
            .delay(for: .seconds(randomDelay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchCommunityList() -> AnyPublisher<[Community], WableError> {
        let communityMockData: [Community] = [
            Community(team: .t1, registrationRate: 0.91),
            Community(team: .gen, registrationRate: 0.88),
            Community(team: .hle, registrationRate: 0.72),
            Community(team: .dk, registrationRate: 0.79),
            Community(team: .kt, registrationRate: 0.65),
            Community(team: .ns, registrationRate: 0.54),
            Community(team: .drx, registrationRate: 0.49),
            Community(team: .bro, registrationRate: 0.37),
            Community(team: .bfx, registrationRate: 0.42),
            Community(team: .dnf, registrationRate: 0.33)
        ]

        return .just(communityMockData)
            .delay(for: .seconds(randomDelay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func register(for communityTeam: LCKTeam) -> AnyPublisher<Double, WableError> {
        return .just(88.0)
            .delay(for: .seconds(randomDelay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
