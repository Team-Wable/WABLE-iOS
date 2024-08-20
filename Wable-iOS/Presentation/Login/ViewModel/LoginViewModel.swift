//
//  LoginViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import AuthenticationServices
import Combine
import Foundation

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

final class LoginViewModel: NSObject, ViewModelType {
    
    private let cancelBag = CancelBag()
    
//    private let networkProvider: NetworkServiceType
    private let userInfoPublisher = PassthroughSubject<Bool, Never>()
    
//    init(networkProvider: NetworkServiceType) {
//        self.networkProvider = networkProvider
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    struct Input {
        let kakaoButtonTapped: AnyPublisher<Void, Never>?
        let appleButtonTapped: AnyPublisher<Void, Never>?
    }
    
    struct Output {
        let userInfoPublisher: PassthroughSubject<Bool, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.kakaoButtonTapped?
            .sink {
                self.performKakaoLogin()
            }
            .store(in: cancelBag)
        
        input.appleButtonTapped?
            .sink {
                self.performAppleLogin()
            }
            .store(in: cancelBag)
        
        return Output(userInfoPublisher: userInfoPublisher)
    }
    
    private func performKakaoLogin() {
        print("performKakaoLogin")
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                print("oauthToken1: \(oauthToken)")
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                print("oauthToken2: \(oauthToken)")
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        }
    }
    
    private func performAppleLogin() {
        let appleProvider = ASAuthorizationAppleIDProvider()
        let request = appleProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    private func handleKakaoLoginResult(oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            print("카카오 로그인 에러")
            print(error)
        } else if let accessToken = oauthToken?.accessToken {
            print("카카오 로그인 accessToken: \(accessToken)")
            self.userInfoPublisher.send(true)
            
            // 카카오 로그인 서버통신
//            Task {
//                do {
//                    let result = try await self.postSocialLoginAPI(socialPlatform: "KAKAO", accessToken: accessToken, userName: nil)?.data
//                    guard let isNewUser = result?.isNewUser else { return }
//                    let nickname = result?.nickName ?? ""
//                    if !isNewUser && !nickname.isEmpty {
//                        self.userInfoPublisher.send(false)
//                    } else {
//                        self.userInfoPublisher.send(true)
//                    }
//                } catch {
//                    print(error)
//                }
//            }
        }
    }
}

extension LoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        if let fullName = credential.fullName,
           let identifyToken = credential.identityToken {
            let userName = (fullName.familyName ?? "") + (fullName.givenName ?? "")
            
            if let accessToken = String(data: identifyToken, encoding: .utf8) {
                // 애플로그인 서버통신
                print("애플 로그인 accessToken: \(accessToken)")
                self.userInfoPublisher.send(true)
//                Task {
//                    do {
//                        let result = try await self.postSocialLoginAPI(socialPlatform: "APPLE", accessToken: accessToken ?? "", userName: userName)?.data
//                        guard let isNewUser = result?.isNewUser else { return }
//                        let nickname = result?.nickName ?? ""
//                        if !isNewUser && !nickname.isEmpty {
//                            self.userInfoPublisher.send(false)
//                        } else {
//                            self.userInfoPublisher.send(true)
//                        }
//                    } catch {
//                        print(error)
//                    }
//                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}
