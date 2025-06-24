//
//  CommunityRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class CommunityRepositoryImpl {
    private let provider = APIProvider<CommunityTargetType>()
}

extension CommunityRepositoryImpl: CommunityRepository {
    func updateRegistration(communityName: String) -> AnyPublisher<Double, WableError> {
        return provider.request(
            .updateRegister(
                request: DTO.Request.UpdateRegister(
                    communityName: communityName
                )
            ),
            for: DTO.Response.RegisterResult.self
        )
        .map { $0.registrationRate }
        .mapWableError()
    }
    
    func fetchCommunityList() -> AnyPublisher<[Community], WableError> {
        return provider.request(
            .fetchCommunityList,
            for: [DTO.Response.FetchCommunites].self
        )
        .map(CommunityMapper.toDomain)
        .mapWableError()
    }
    
    func checkUserRegistration() -> AnyPublisher<CommunityRegistration, WableError> {
        return provider.request(.isUserRegistered, for: DTO.Response.IsUserRegistered.self)
            .map(CommunityMapper.toDomain)
            .mapWableError()
    }
}

struct MockCommunityRepository: CommunityRepository {
    private var randomDelay: TimeInterval { Double.random(in: 0.7...1.3) }
    
    func updateRegistration(communityName: String) -> AnyPublisher<Double, WableError> {
        return .just(88.0)
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
    
    func checkUserRegistration() -> AnyPublisher<CommunityRegistration, WableError> {
        let registration = CommunityRegistration(team: nil, hasRegisteredTeam: false)
        return .just(registration)
            .delay(for: .seconds(randomDelay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
