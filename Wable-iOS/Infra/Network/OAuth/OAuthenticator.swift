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
    
    private let errorMonitor: OAuthErrorMonitor
    private let tokenStorage: TokenStorage
    
    init(errorMonitor: OAuthErrorMonitor, tokenStorage: TokenStorage) {
        self.errorMonitor = errorMonitor
        self.tokenStorage = tokenStorage
    }
    
    /// 토큰 재발급 API를 제외하고 다른 API 통신을 진행할 때 헤더를 설정하는 메서드
    /// 소셜 로그인 통신 시 카카오 엑세스 토큰 무조건 삽입되도록 설정
    func apply(_ credential: OAuthCredential, to urlRequest: inout URLRequest) {
        var headers = urlRequest.headers
        
        do {
            let tokenType: TokenStorage.TokenType = {
                if let urlString = urlRequest.url?.absoluteString, urlString.contains("v2/auth") {
                    WableLogger.log("소셜 로그인을 위해 loginAccessToken으로 헤더 설정", for: .debug)
                    return .loginAccessToken
                } else {
                    WableLogger.log("서버 통신을 위해 wableAccessToken으로 헤더 설정", for: .debug)
                    return .wableAccessToken
                }
            }()
            
            let token = try tokenStorage.load(tokenType)
            WableLogger.log("토큰 불러오기 성공: \(String(token.prefix(10)))...", for: .debug)
            
            headers.add(.authorization(bearerToken: token))
            urlRequest.headers = headers
            
            WableLogger.log("요청 헤더에 토큰 추가 완료", for: .debug)
        } catch {
            WableLogger.log("토큰 불러오기 실패: \(error.localizedDescription)", for: .error)
        }
    }
    
    /// API 요청 중 에러가 발생했을 때 응답 코드가 401인 경우만 refresh가 실행되도록 처리하는 메서드
    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: any Error
    ) -> Bool {
        return errorMonitor.isUnauthorized
    }
    
    /// 인증이 필요한 urlRequest에 대해서만 true를 리턴해 refresh가 실행되도록 처리하는 메서드
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
        let token = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        
        return urlRequest.headers["Authorization"] == token
    }

    /// 토큰 갱신을 위해 updateTokenStatus를 실행하고 받아온 결과를 TokenStorage에 저장하는 메서드
    func refresh(
        _ credential: OAuthCredential,
        for session: Alamofire.Session,
        completion: @escaping (Result<OAuthCredential, any Error>) -> Void
    ) {
        let repository = OAuthTokenProvider()
        
        repository.updateTokenStatus()
            .sink(
                receiveCompletion: { status in
                    if case .failure(let error) = status {
                        let userSessionRepository = UserSessionRepositoryImpl(
                            userDefaults: UserDefaultsStorage(
                            jsonEncoder: JSONEncoder(),
                            jsonDecoder: JSONDecoder()
                            ))
                        
                        if error == .signinRequired {
                            guard let id = userSessionRepository.fetchActiveUserID() else { return }
                            
                            userSessionRepository.removeUserSession(forUserID: id)
                            
                            AuthEventManager.shared.tokenExpiredSubject.send()
                        }
                        
                        completion(.failure(error))
                    }
                }, receiveValue: { token in
                    do {
                        try self.tokenStorage.save(token.accessToken, for: .wableAccessToken)
                        try self.tokenStorage.save(token.refreshToken, for: .wableRefreshToken)
                    } catch {
                        completion(.failure(error))
                        return
                    }
                    
                    completion(.success(credential))
                }
            )
            .cancel()
    }
}
