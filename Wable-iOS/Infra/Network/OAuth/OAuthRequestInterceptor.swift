//
//  OAuthRequestInterceptor.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 11/16/25.
//

import Combine
import UIKit

import Alamofire

final class OAuthRequestInterceptor: RequestInterceptor {

    // MARK: - Property
    
    private let logoutHandler: (@Sendable () -> Void)?
    private let oauthProvider: OAuthProvider
    private let cancelBag: CancelBag

    // MARK: - LifeCycle
    
    init(
        logoutHandler: (@Sendable () -> Void)?,
        oauthProvider: OAuthProvider,
        cancelBag: CancelBag
    ) {
        self.logoutHandler = logoutHandler
        self.oauthProvider = oauthProvider
        self.cancelBag = cancelBag
    }

    // MARK: - RequestAdapter
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        guard let urlString = urlRequest.url?.absoluteString else {
            completion(.success(urlRequest))
            return
        }

        do {
            let tokenType: TokenStorage.TokenType = resolveTokenType(for: urlString)

            if urlString.contains("v1/auth/token") {
                try setRetryHeader(for: &urlRequest)
            } else {
                try setAuthorizationHeader(for: &urlRequest, with: tokenType)
            }

            WableLogger.log("요청 헤더에 토큰 추가 완료: \(urlRequest.headers)", for: .debug)
            completion(.success(urlRequest))
        } catch {
            WableLogger.log("토큰 없이 요청 진행: \(urlString)", for: .debug)
            completion(.success(urlRequest))
        }
    }

    // MARK: - RequestRetrier
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let (shouldRetry, url) = shouldRetryRequest(request)
        
        guard shouldRetry, let url = url else {
            completion(.doNotRetry)
            return
        }
        
        WableLogger.log("401 에러 감지 - 토큰 재발급 시도: \(url)", for: .debug)
        
        oauthProvider.refreshToken()
            .sink(
                receiveCompletion: { [weak self] in
                    self?.handleRefreshCompletion($0, completion: completion)
                }, receiveValue: { [weak self] in
                    self?.handleRefreshSuccess($0, completion: completion)
                }
            )
            .store(in: cancelBag)
    }
}

// MARK: - RequestAdapter Helper

private extension OAuthRequestInterceptor {
    func resolveTokenType(for urlString: String) -> TokenStorage.TokenType {
        if urlString.contains("v2/auth") {
            WableLogger.log("소셜 로그인을 위해 loginAccessToken으로 헤더 설정", for: .debug)
            return .loginAccessToken
        } else {
            WableLogger.log("서버 통신을 위해 wableAccessToken으로 헤더 설정", for: .debug)
            return .wableAccessToken
        }
    }
    
    func setRetryHeader(for urlRequest: inout URLRequest) throws {
        let accessToken = try oauthProvider.loadToken(for: .wableAccessToken)
        let refreshToken = try oauthProvider.loadToken(for: .wableRefreshToken)

        WableLogger.log("토큰 재발급을 위한 현재 토큰 불러오기 성공: \(String(accessToken.prefix(10)))...", for: .debug)

        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        urlRequest.headers.add(name: "Refresh", value: "Bearer \(refreshToken)")
    }

    func setAuthorizationHeader(for urlRequest: inout URLRequest, with tokenType: TokenStorage.TokenType) throws {
        let token = try oauthProvider.loadToken(for: tokenType)
        WableLogger.log("토큰 불러오기 성공: \(String(token.prefix(10)))...", for: .debug)

        urlRequest.headers.add(.authorization(bearerToken: token))
    }
}

// MARK: - RequestRetrier Helper

private extension OAuthRequestInterceptor {
    func shouldRetryRequest(_ request: Request) -> (shouldRetry: Bool, url: String?) {
        guard let response = request.response,
              response.statusCode == 401
        else {
            return (false, nil)
        }
        
        guard let url = request.request?.url?.absoluteString,
              !url.contains("v1/auth/token")
        else {
            WableLogger.log("토큰 재발급 API에서 401 에러 발생 - 재시도하지 않음", for: .error)
            return (false, nil)
        }
        
        return (true, url)
    }
    
    func handleRefreshCompletion(_ result: Subscribers.Completion<WableError>, completion: @escaping (RetryResult) -> Void) {
        if case let .failure(error) = result {
            WableLogger.log("토큰 재발급 실패: \(error)", for: .error)

            if error == .signinRequired {
                oauthProvider.removeSession()
                logoutHandler?()
            }
            completion(.doNotRetry)
        }
    }
    
    func handleRefreshSuccess(_ token: Token, completion: @escaping (RetryResult) -> Void) {
        do {
            try oauthProvider.saveToken(token: token)
            WableLogger.log("토큰 재발급 성공 - 요청 재시도", for: .debug)
            completion(.retry)
        } catch {
            WableLogger.log("토큰 저장 실패: \(error)", for: .error)
            oauthProvider.removeSession()
            logoutHandler?()
            completion(.doNotRetry)
        }
    }
}
