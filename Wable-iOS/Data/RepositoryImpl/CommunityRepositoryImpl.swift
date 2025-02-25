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
    func updatePreRegister(communityName: LCKTeam) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .updatePreRegister(
                request: DTO.Request.UpdatePreRegister(
                    communityName: communityName.rawValue
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
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
}
