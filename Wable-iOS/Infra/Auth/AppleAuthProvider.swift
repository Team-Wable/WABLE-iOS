//
//  AppleAuthProvider.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import AuthenticationServices
import Combine

final class AppleAuthProvider: NSObject, AuthProvider {
    private let tokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    private var promise: ((Result<String?, WableError>) -> Void)?
    
    func authenticate() -> AnyPublisher<String?, WableError> {
        return Future<String?, WableError> { promise in
            self.promise = promise
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthProvider: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let promise = self.promise else { return }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let token = appleIDCredential.identityToken,
           let tokenText = String(data: token, encoding: .utf8) {
            WableLogger.log("애플 로그인 토큰 추출 완료", for: .debug)
            
            do {
                try tokenStorage.save(tokenText, for: .loginAccessToken)
                WableLogger.log("애플 로그인 토큰 저장 완료", for: .debug)
                promise(.success(appleIDCredential.fullName?.formatted()))
            } catch {
                WableLogger.log("애플 로그인 토큰 저장 중 오류 발생: \(error)", for: .error)
                promise(.failure(.networkError))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let promise = self.promise else { return }
        
        promise(.failure(.failedToAppleLogin))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            return ASPresentationAnchor()
        }
        
        return window
    }
}
