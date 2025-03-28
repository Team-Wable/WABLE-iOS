//
//  MoyaLoggingPlugin.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/15/25.
//

import Foundation

import Moya

final class MoyaLoggingPlugin: PluginType {
    
    // MARK: Property
    
    typealias LogoutHandler = () -> Void
    private let cancelBag = CancelBag()
    private let logoutHandler: LogoutHandler?
    private let tokenStorage: TokenStorage
    
    // MARK: - LifeCycle

    init(
        logoutHandler: LogoutHandler? = nil,
        tokenStorage: TokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    ) {
        self.logoutHandler = logoutHandler
        self.tokenStorage = tokenStorage
    }
    
    /// Logs details of the outgoing HTTP request.
    /// 
    /// Extracts and prints essential information from the HTTP request, including its HTTP method, URL, headers, and body. If the request lacks a valid URLRequest, it prints an error message indicating the request is invalid.
    /// 
    /// - Parameters:
    ///   - request: A wrapper that provides access to the underlying URLRequest to be sent.
    ///   - target: The target endpoint associated with the request.
    
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            print("--> 유효하지 않은 요청")
            return
        }
        
        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "메소드값이 nil입니다."
        var log = "----------------------------------------------------\n1️⃣[\(method)] \(url)\n----------------------------------------------------\n"
        log.append("2️⃣API: \(target)\n")
        
        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            log.append("header: \(headers)\n")
        }
        
        if let body = httpRequest.httpBody, let bodyString = String(
            bytes: body,
            encoding: String.Encoding.utf8
        ) {
            log.append("body: \(bodyString)\n")
        }
        
        log.append("------------------- END \(method) -------------------")
        print(log)
    }
    
    /// Processes the result of an HTTP request for a specified target.
    ///
    /// For a successful response, this method logs the response details using `onSucceed(_, target:)` and checks for authentication errors with `checkForAuthError(_:)`. In the case of a failure, it logs the error via `onFail(_, target:)` and, if an HTTP response is available, it examines that response for potential authentication issues.
    ///
    /// - Parameters:
    ///   - result: The outcome of the HTTP request, containing either a successful response or an error.
    ///   - target: The network target associated with the request.
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            self.onSucceed(response, target: target)
            self.checkForAuthError(response)
        case let .failure(error):
            self.onFail(error, target: target)
            if let response = error.response {
                self.checkForAuthError(response)
            }
        }
    }
    
    func onSucceed(_ response: Response, target: TargetType) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        var log = "------------------- Reponse가 도착했습니다. -------------------"
        log.append("\n3️⃣[\(statusCode)] \(url)\n")
        log.append("API: \(target)\n")
        log.append("Status Code: [\(statusCode)]\n")
        log.append("URL: \(url)\n")
        log.append("response: \n")
        if let reString = String(bytes: response.data, encoding: String.Encoding.utf8) {
            log.append("4️⃣\(reString)\n")
        }
        log.append("------------------- END HTTP -------------------")
        print(log)
    }
    
    /// Logs details for a failed network request.
    ///
    /// If the error contains a valid HTTP response, the handler delegates logging to the provided success handler (`onSucceed`). Otherwise, it constructs and prints an error log that includes the error code and a descriptive message.
    ///
    /// - Parameters:
    ///   - error: The Moya error that occurred during the network request.
    ///   - target: The API target associated with the network request.
    func onFail(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            onSucceed(response, target: target)
            return
        }
        var log = "네트워크 오류"
        log.append("<-- \(error.errorCode)\n")
        log.append("\(error.failureReason ?? error.errorDescription ?? "unknown error")\n")
        log.append("<-- END HTTP")
        print(log)
    }
}

// MARK: - Private Extension

private extension MoyaLoggingPlugin {
    /// Checks the provided HTTP response for an authentication error (HTTP 401) that is not from the token refresh endpoint.
    /// 
    /// If such an error is detected, the method initiates a token refresh process via an OAuth token provider. On a failure due
    /// to a sign-in requirement, it clears the stored access and refresh tokens and triggers the logout handler. On a successful
    /// refresh, new tokens are saved to storage; if saving fails, an error is logged and logout is triggered.
    /// 
    /// - Parameter response: The HTTP response to inspect for authentication errors.
    private func checkForAuthError(_ response: Response) {
        guard let condtion = response.response?.url?.absoluteString.contains("v1/auth/token"),
              response.statusCode == 401 && !condtion else { return }
        
        let tokenProvider = OAuthTokenProvider()
        
        tokenProvider.updateTokenStatus()
            .withUnretained(self)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if error == .signinRequired {
                        try? self?.tokenStorage.delete(.wableAccessToken)
                        try? self?.tokenStorage.delete(.wableRefreshToken)
                        
                        self?.logoutHandler?()
                    }
                }
            } receiveValue: { owner, token in
                do {
                    try owner.tokenStorage.save(token.accessToken, for: .wableAccessToken)
                    try owner.tokenStorage.save(token.refreshToken, for: .wableRefreshToken)
                } catch {
                    WableLogger.log("토큰 재발급 중 문제 발생", for: .error)
                    owner.logoutHandler?()
                }
            }
            .store(in: cancelBag)
    }
}
