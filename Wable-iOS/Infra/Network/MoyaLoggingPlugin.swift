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
    
    // MARK: - Request 보낼 시 호출
    
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
    
    // MARK: - Response 받을 시 호출
    
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
                    
                    let toast = ToastView(status: .caution, message: "다시 시도하세요")
                    toast.show()
                } catch {
                    WableLogger.log("당신은 이제 망햇습니다...", for: .error)
                    owner.logoutHandler?()
                }
            }
            .store(in: cancelBag)
    }
}
