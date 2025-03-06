//
//  KakaoAuthProvider.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

import KakaoSDKAuth
import KakaoSDKUser

typealias KakaoUserAPI = UserApi

final class KakaoAuthProvider: AuthProvider {
    private let tokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    
    func authenticate() -> AnyPublisher<String?, WableError> {
        return Future<String?, WableError> { promise in
            if KakaoUserAPI.isKakaoTalkLoginAvailable() {
                KakaoUserAPI.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                    self?.handleKakaoAuthResult(oauthToken: oauthToken, error: error, promise: promise)
                }
            } else {
                KakaoUserAPI.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                    self?.handleKakaoAuthResult(oauthToken: oauthToken, error: error, promise: promise)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Extension

private extension KakaoAuthProvider {
    func handleKakaoAuthResult(
        oauthToken: OAuthToken?,
        error: Error?,
        promise: @escaping (Result<String?, WableError>) -> Void
    ) {
        if error != nil {
            promise(.failure(.kakaoUnauthorizedUser))
            return
        }
        
        guard let token = oauthToken?.accessToken else {
            promise(.failure(.kakaoUnauthorizedUser))
            return
        }
        
        do {
            try tokenStorage.save(token, for: .kakaoAccessToken)
            promise(.success(token))
        } catch {
            promise(.failure(.networkError))
        }
    }
}
