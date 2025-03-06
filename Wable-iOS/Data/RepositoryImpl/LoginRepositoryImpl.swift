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
    private let authProviders: [SocialPlatform: AuthProvider]
    
    init(authProviders: [SocialPlatform: AuthProvider] = [
        .apple: AppleAuthProvider(),
        .kakao: KakaoAuthProvider()
    ]) {
        self.authProviders = authProviders
    }
}

extension LoginRepositoryImpl: LoginRepository {
    func fetchUserAuth(platform: SocialPlatform, userName: String?) -> AnyPublisher<Account, WableError> {
        guard let provider = authProviders[platform] else {
            return .fail(.unknownError)
        }
        
        return provider.authenticate()
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Account, WableError> in
                return owner.provider.request(
                    .fetchUserAuth(
                        request: DTO.Request.CreateAccount(
                            socialPlatform: platform.rawValue,
                            userName: userName
                        )
                    ),
                    for: DTO.Response.CreateAccount.self
                )
                .map(LoginMapper.toDomain)
                .mapWableError()
            }
            .eraseToAnyPublisher()
    }
}
