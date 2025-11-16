//
//  TokenInterceptorPlugin.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 11/16/25.
//

import UIKit

import Moya

public final class TokenInterceptorPlugin: PluginType {
    
    // MARK: Property
    
    private let cancelBag = CancelBag()
    private let oAuthTokenProvider: OAuthTokenProvider
    
    @Injected private var userSessionRepository: UserSessionRepository
    @Injected private var tokenStorage: TokenStorage
    
    // MARK: - LifeCycle
    
    init(oAuthTokenProvider: OAuthTokenProvider) {
        self.oAuthTokenProvider = oAuthTokenProvider
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard case let .failure(error) = result,
              let response = error.response?.response,
              shouldRefreshToken(for: response)
        else {
            return
        }
    }
}

private extension TokenInterceptorPlugin {
    func shouldRefreshToken(for response: HTTPURLResponse) -> Bool {
        guard let url = response.url?.absoluteString else { return false }
        
        let isTokenAPI = url.contains("v1/auth/token")
        let isUnauthorized = response.statusCode == 401
        
        return !isTokenAPI && isUnauthorized
    }
    
    func updateTokenStatus() {
        oAuthTokenProvider.updateTokenStatus()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                guard case let .failure(error) = completion else { return }
                
                if error == .signinRequired {
                    deleteToken()
                    logout()
                }
            }, receiveValue: { [weak self] token in
                guard let self = self else { return }
                
                saveToken(token: token)
                presentRetryError()
            })
            .store(in: cancelBag)
    }
    
    func deleteToken() {
        tokenStorage.delete(.wableAccessToken)
        tokenStorage.delete(.wableRefreshToken)
    }
    
    func saveToken(token: Token) {
        tokenStorage.save(token.accessToken, for: .wableAccessToken)
        tokenStorage.save(token.refreshToken, for: .wableRefreshToken)
    }
    
    func presentRetryError() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            return
        }
        
        let viewController = WableSheetViewController(title: "알 수 없는 오류입니다.\n재시도하세요.")
        viewController.addAction(WableSheetAction.init(title: "확인", style: .primary))
        
        rootViewController.present(viewController, animated: true)
    }
    
    func logout() {
        userSessionRepository.updateActiveUserID(nil)
    }
}

private extension TokenInterceptorPlugin {
    struct Constant {
        static let tokenAPIEndpoint: String = "v1/auth/token"
    }
}
