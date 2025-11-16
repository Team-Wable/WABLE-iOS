//
//  OAuthTokenProvider.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/28/25.
//


import Combine

import Moya

public final class OAuthTokenProvider {
    private let provider = APIProvider<LoginTargetType>()
}

extension OAuthTokenProvider {
    func updateTokenStatus() -> AnyPublisher<Token, WableError> {
        return provider.request(
            .fetchTokenStatus,
            for: DTO.Response.UpdateToken.self
        )
        .map(LoginMapper.toDomain)
        .mapWableError()
    }
}
