//
//  OAuthRequestInterceptor.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 11/16/25.
//

import Combine
import Foundation
import UIKit

import Alamofire
@preconcurrency import Moya

final class OAuthRequestInterceptor: RequestInterceptor {

    // MARK: - Property

    private let tokenRefreshProvider: MoyaProvider<LoginTargetType>
    private let logoutHandler: (@Sendable () -> Void)?
    private let jsonDecoder = JSONDecoder()
    private let tokenStorage: TokenStorage
    private let removeUserSessionUseCase: RemoveUserSessionUseCase
    private let cancelBag: CancelBag

    // MARK: - LifeCycle

    init(
        tokenStorage: TokenStorage,
        removeUserSessionUseCase: RemoveUserSessionUseCase,
        logoutHandler: (@Sendable () -> Void)? = nil,
        cancelBag: CancelBag
    ) {
        self.tokenStorage = tokenStorage
        self.removeUserSessionUseCase = removeUserSessionUseCase
        self.tokenRefreshProvider = MoyaProvider<LoginTargetType>(plugins: [MoyaLoggingPlugin()])
        self.logoutHandler = logoutHandler
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
        
        refreshToken()
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
        let accessToken = try tokenStorage.load(.wableAccessToken)
        let refreshToken = try tokenStorage.load(.wableRefreshToken)

        WableLogger.log("토큰 재발급을 위한 현재 토큰 불러오기 성공: \(String(accessToken.prefix(10)))...", for: .debug)

        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        urlRequest.headers.add(name: "Refresh", value: "Bearer \(refreshToken)")
    }

    func setAuthorizationHeader(for urlRequest: inout URLRequest, with tokenType: TokenStorage.TokenType) throws {
        let token = try tokenStorage.load(tokenType)
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
                removeUserSessionUseCase.removeUserSession()
                logoutHandler?()
            }

            completion(.doNotRetry)
        }
    }
    
    func handleRefreshSuccess(_ token: Token, completion: @escaping (RetryResult) -> Void) {
        do {
            try saveSession(token: token)
            WableLogger.log("토큰 재발급 성공 - 요청 재시도", for: .debug)
            completion(.retry)
        } catch {
            WableLogger.log("토큰 저장 실패: \(error)", for: .error)
            removeUserSessionUseCase.removeUserSession()
            logoutHandler?()
            completion(.doNotRetry)
        }
    }
}

// MARK: - Token Helper

private extension OAuthRequestInterceptor {
    private func saveSession(token: Token) throws {
        try tokenStorage.save(token.accessToken, for: .wableAccessToken)
        try tokenStorage.save(token.refreshToken, for: .wableRefreshToken)
    }

    private func refreshToken() -> AnyPublisher<Token, WableError> {
        return tokenRefreshProvider.requestPublisher(.fetchTokenStatus)
            .map { $0.data }
            .decode(type: BaseResponse<DTO.Response.UpdateToken>.self, decoder: jsonDecoder)
            .tryMap { response -> DTO.Response.UpdateToken in
                guard response.success else { throw WableError.signinRequired }
                guard let data = response.data else { throw WableError.unknownError }
                return data
            }
            .map(LoginMapper.toDomain)
            .mapError { ($0 as? WableError) ?? .unknownError }
            .eraseToAnyPublisher()
    }
}

