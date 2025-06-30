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
            promise(.failure(.failedToKakaoLogin))
            return
        }
        
        guard let token = oauthToken?.accessToken else {
            promise(.failure(.failedToKakaoLogin))
            return
        }
        
        do {
            try tokenStorage.save(token, for: .loginAccessToken)
            WableLogger.log("카카오 로그인 토큰 저장 완료", for: .debug)
            promise(.success(token))
        } catch {
            WableLogger.log("카카오 로그인 토큰 저장 중 오류 발생: \(error)", for: .debug)
            promise(.failure(.networkError))
        }
    }
}
