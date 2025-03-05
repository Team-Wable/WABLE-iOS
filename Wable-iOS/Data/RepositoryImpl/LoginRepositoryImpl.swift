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
    private let appleAuthProvider = AppleAuthProvider()
    private let kakaoAuthProvider = KakaoAuthProvider()
}

extension LoginRepositoryImpl: LoginRepository {
    func fetchAppleAuth() -> AnyPublisher<String, WableError> {
        return appleAuthProvider.authenticate()
    }
    
    func fetchKakaoAuth() -> AnyPublisher<Void, WableError> {
        return kakaoAuthProvider.authenticate()
    }
    
    func fetchUserAuth(platform: String, userName: String?) -> AnyPublisher<Account, WableError> {
        return provider.request(
            .fetchUserAuth(
                request: DTO.Request.CreateAccount(
                    socialPlatform: platform,
                    userName: userName
                )
            ),
            for: DTO.Response.CreateAccount.self
        )
        .map(LoginMapper.toDomain)
        .mapWableError()
    }
}
