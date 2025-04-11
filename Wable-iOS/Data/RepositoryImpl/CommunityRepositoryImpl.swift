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
    func updateRegister(communityName: String) -> AnyPublisher<Double, WableError> {
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
    
    func isUserRegistered() -> AnyPublisher<CommunityRegistration, WableError> {
        return provider.request(.isUserRegisterd, for: DTO.Response.IsUserRegistered.self)
            .map(CommunityMapper.toDomain)
            .mapWableError()
    }
}
