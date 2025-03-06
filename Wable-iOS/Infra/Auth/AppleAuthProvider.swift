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
            
            let request = ASAuthorizationAppleIDProvider().createRequest().then {
                $0.requestedScopes = [.fullName, .email]
            }
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request]).then {
                $0.delegate = self
                $0.presentationContextProvider = self
            }
            
            authorizationController.performRequests()
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthProvider: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let promise = self.promise else { return }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            try? tokenStorage.save("", for: .kakaoAccessToken)
            promise(.success(appleIDCredential.user))
        } else {
            promise(.failure(.failedToValidateAppleLogin))
        }
        
        self.promise = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let promise = self.promise else { return }
        
        promise(.failure(.failedToValidateAppleLogin))
        
        self.promise = nil
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
