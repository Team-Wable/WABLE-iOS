//
//  OAuthTokenProvider.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/28/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class OAuthTokenProvider {
    func updateTokenStatus() -> AnyPublisher<Token, WableError> {
        return provider.request(
            .fetchTokenStatus,
            for: DTO.Response.UpdateToken.self
        )
        .map(LoginMapper.toDomain)
        .mapWableError()
    }
    
    private let provider = APIProvider<LoginTargetType>()
}
