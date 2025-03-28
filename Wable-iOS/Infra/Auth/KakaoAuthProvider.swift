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
    /// Processes the result of a Kakao authentication attempt by verifying the OAuth token, saving it if valid, and completing the provided promise accordingly.
    ///
    /// - Parameters:
    ///   - oauthToken: The OAuth token received from the Kakao authentication response, if available.
    ///   - error: An error encountered during the authentication request, if any.
    ///   - promise: A closure to be called with the result. On success, it returns the saved access token; on failure, it returns a corresponding WableError.
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
            try tokenStorage.save(token, for: .loginAccessToken)
            WableLogger.log("카카오 로그인 토큰 저장 완료", for: .debug)
            promise(.success(token))
        } catch {
            WableLogger.log("카카오 로그인 토큰 저장 중 오류 발생: \(error)", for: .debug)
            promise(.failure(.networkError))
        }
    }
}
