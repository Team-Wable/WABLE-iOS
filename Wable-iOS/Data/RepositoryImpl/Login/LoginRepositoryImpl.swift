//
//  LoginRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class LoginRepositoryImpl {
    private let provider = APIProvider<LoginTargetType>()
}

extension LoginRepositoryImpl: LoginRepository {
    func updateTokenStatus() -> AnyPublisher<Token, any Error> {
        return provider.request(
            .fetchTokenStatus,
            for: DTO.Response.UpdateToken.self
        )
        .map { token in
            LoginMapper.tokenMapper(token)
        }
        .normalizeError()
    }
    
    func fetchUserAuth(platform: String, userName: String) -> AnyPublisher<Account, any Error> {
        return provider.request(
            .fetchUserAuth(
                request: DTO.Request.CreateAccount(
                    socialPlatform: platform,
                    userName: userName
                )
            ),
            for: DTO.Response.CreateAccount.self
        )
        .map { account in
            LoginMapper.accountMapper(account)
        }
        .normalizeError()
    }
}
