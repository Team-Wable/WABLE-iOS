//
//  KakaoAuthProvider.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

import KakaoSDKAuth
import KakaoSDKUser

final class KakaoAuthProvider {
    private let tokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    
    func authenticate() -> AnyPublisher<Void, WableError> {
        let UserAPI = UserApi.self
        
        return Future<Void, WableError> { promise in
            if UserAPI.isKakaoTalkLoginAvailable() {
                UserAPI.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                    self?.handleKakaoAuthResult(oauthToken: oauthToken, error: error, promise: promise)
                }
            } else {
                UserAPI.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                    self?.handleKakaoAuthResult(oauthToken: oauthToken, error: error, promise: promise)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension KakaoAuthProvider {
    private func handleKakaoAuthResult(
        oauthToken: OAuthToken?,
        error: Error?,
        promise: @escaping (Result<Void, WableError>) -> Void
    ) {
        if error != nil {
            promise(.failure(.kakaoUnauthorizedUser))
            return
        }
        
        if let token = oauthToken?.accessToken {
            try? tokenStorage.save(token, for: .kakaoAccessToken)
        } else {
            promise(.failure(.kakaoUnauthorizedUser))
            return
        }
    }
}
