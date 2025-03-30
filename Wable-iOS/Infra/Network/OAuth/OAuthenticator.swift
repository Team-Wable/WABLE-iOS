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
    /// 소셜 로그인 통신 시 로그인 엑세스 토큰 무조건 삽입되도록 설정
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
    
    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: any Error
    ) -> Bool {
        return false
    }
    
    /// 인증이 필요한 urlRequest에 대해서만 true를 리턴해 refresh가 실행되도록 처리하는 메서드
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
        let token = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        
        return urlRequest.headers["Authorization"] == token
    }
    
    
    func refresh(
        _ credential: OAuthCredential,
        for session: Alamofire.Session,
        completion: @escaping (Result<OAuthCredential, any Error>) -> Void
    ) { }
}
