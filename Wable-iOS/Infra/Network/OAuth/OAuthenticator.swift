//
//  OAuthenticator.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/25/25.
//


import Foundation

import Alamofire

final class OAuthenticator: Authenticator {
    typealias Credential = OAuthCredential
    
    private let tokenStorage: TokenStorage
    
    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }
    
    /// 토큰 재발급 API를 제외하고 다른 API 통신을 진행할 때 헤더를 설정하는 메서드
    /// Updates the URLRequest with the appropriate OAuth token headers.
    ///
    /// The method determines which token(s) to attach based on the URL:
    /// - For URLs containing "v1/auth/token", it loads both an access token and a refresh token from storage, adding them as "Authorization" and "Refresh" headers respectively.
    /// - Otherwise, it selects a token type based on whether the URL contains "v2/auth" (using a social login token) or not (using a standard token) and adds it as the "Authorization" header.
    /// If token retrieval fails, an error is logged and the URLRequest remains unchanged.
    ///
    /// - Parameters:
    ///   - credential: An OAuth credential. Although provided, the token is retrieved from storage rather than using this parameter directly.
    ///   - urlRequest: The URL request that will be modified with the appropriate OAuth headers.
    func apply(_ credential: OAuthCredential, to urlRequest: inout URLRequest) {
        guard let urlString = urlRequest.url?.absoluteString else { return }
        var headers = urlRequest.headers
        
        do {
            let tokenType: TokenStorage.TokenType = {
                if urlString.contains("v2/auth") {
                    WableLogger.log("소셜 로그인을 위해 loginAccessToken으로 헤더 설정", for: .debug)
                    return .loginAccessToken
                } else {
                    WableLogger.log("서버 통신을 위해 wableAccessToken으로 헤더 설정", for: .debug)
                    return .wableAccessToken
                }
            }()
            
            if urlString.contains("v1/auth/token") {
                let accessToken = try tokenStorage.load(.wableAccessToken)
                let refreshToken = try tokenStorage.load(.wableRefreshToken)
                
                WableLogger.log("토큰 재발급을 위한 현재 토큰 불러오기 성공: \(String(accessToken.prefix(10)))...", for: .debug)
                
                headers.add(.authorization(bearerToken: accessToken))
                headers.add(name: "Refresh", value: "Bearer \(refreshToken)")
            } else {
                let token = try tokenStorage.load(tokenType)
                WableLogger.log("토큰 불러오기 성공: \(String(token.prefix(10)))...", for: .debug)
                
                headers.add(.authorization(bearerToken: token))
            }
            
            urlRequest.headers = headers
            
            WableLogger.log("요청 헤더에 토큰 추가 완료: \(urlRequest.headers)", for: .debug)
        } catch {
            WableLogger.log("토큰 불러오기 실패: \(error.localizedDescription)", for: .error)
        }
    }
    
    /// Indicates whether the authentication error triggered a request retry.
    /// 
    /// This method always returns false, signifying that no additional action is taken when an authentication error occurs.
    /// 
    /// - Parameters:
    ///   - urlRequest: The request that resulted in the authentication error.
    ///   - response: The HTTP response received from the server.
    ///   - error: The error encountered due to authentication failure.
    /// - Returns: Always returns false.
    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: any Error
    ) -> Bool {
        return false
    }
    
    /// Determines whether the provided URLRequest is authenticated with the specified OAuth credential.
    /// 
    /// This method compares the "Authorization" header in the URLRequest with the bearer token derived
    /// from the credential's access token to verify proper authentication.
    /// 
    /// - Parameters:
    ///   - urlRequest: The URLRequest to check for authentication.
    ///   - credential: The OAuth credential containing the access token.
    /// - Returns: True if the "Authorization" header in the request matches the credential's token, false otherwise.
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
        let token = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        
        return urlRequest.headers["Authorization"] == token
    }
    
    
    /// Stub implementation for refreshing OAuth credentials.
    /// 
    /// This method is intentionally left unimplemented. It conforms to the protocol
    /// without performing any token refresh operations, and the completion handler is not invoked.
    func refresh(
        _ credential: OAuthCredential,
        for session: Alamofire.Session,
        completion: @escaping (Result<OAuthCredential, any Error>) -> Void
    ) { }
}
