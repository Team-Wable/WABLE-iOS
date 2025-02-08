//
//  MigratedLoginViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/6/25.
//

import AuthenticationServices
import Combine
import Foundation

import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

final class MigratedLoginViewModel: NSObject {
    private let service: LoginAPI
    private let selectedSocialPlatform = CurrentValueSubject<SocialPlatform, Never>(.apple)
    private let userInfoPublisher = PassthroughSubject<Bool, Never>()
    private let showNewUserPopup = PassthroughSubject<Void, Never>()
    private var cancelBag = CancelBag()
    init(service: LoginAPI = LoginAPI.shared) {
        self.service = service
    }
}

extension MigratedLoginViewModel: ViewModelType {
    struct Input {
        let kakaoButtonTapped: AnyPublisher<Void, Never>
        let appleButtonTapped: AnyPublisher<Void, Never>
        let newUserSingleButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let userInfoPublisher: PassthroughSubject<Bool, Never>
        let showNewUserPopupView: PassthroughSubject<Void, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.kakaoButtonTapped
            .sink {
                if loadUserData()?.isFirstUser == true {
                    self.selectedSocialPlatform.send(.kakao)
                    self.showNewUserPopup.send()
                } else {
                    self.performKakaoLogin()
                }
            }
            .store(in: cancelBag)
        
        input.appleButtonTapped
            .sink {
                if loadUserData()?.isFirstUser == true {
                    self.selectedSocialPlatform.send(.apple)
                    self.showNewUserPopup.send()
                } else {
                    self.performAppleLogin()
                }
            }
            .store(in: cancelBag)
        
        input.newUserSingleButtonTapped
            .sink {
                switch self.selectedSocialPlatform.value {
                case .kakao:
                    self.performKakaoLogin()
                case .apple:
                    self.performAppleLogin()
                }
            }
            .store(in: cancelBag)
        
        return Output(
            userInfoPublisher: userInfoPublisher,
            showNewUserPopupView: showNewUserPopup
        )
    }
}


private extension MigratedLoginViewModel {
    func postSocialLogin(platform: SocialPlatform, userName: String?, accessToken: String) {
        let requestBody = SocialLoginRequestDTO(
            socialPlatform: platform.rawValue,
            userName: userName
        )
        
        service.postSocialLogin(requestBody: requestBody, accessToken: accessToken)
            .mapWableNetworkError()
            .replaceError(with: nil)
            .sink { response in
                let userNickname = response?.nickName ?? ""
                let isNewUser = response?.isNewUser ?? true
                let memberId = response?.memberId ?? 0
                let fcmToken = loadUserData()?.fcmToken
                saveUserData(UserInfo(isSocialLogined: true,
                                      isFirstUser: isNewUser,
                                      isJoinedApp: false,
                                      userNickname: userNickname,
                                      memberId: memberId,
                                      userProfileImage: StringLiterals.Network.baseImageURL,
                                      fcmToken: fcmToken ?? "",
                                      isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false,
                                      isAdmin: response?.isAdmin ?? false))
                // KeychainWrapper에 Access Token 저장
                let accessToken = response?.accessToken ?? ""
                print(accessToken)
                KeychainWrapper.saveToken(accessToken, forKey: "accessToken")
                
                // KeychainWrasapper에 Refresh Token 저장
                let refreshToken = response?.refreshToken ?? ""
                KeychainWrapper.saveToken(refreshToken, forKey: "refreshToken")
                
                
                guard let isNewUser = response?.isNewUser else { return }
                let nickname = response?.nickName ?? ""
                if !isNewUser && !nickname.isEmpty {
                    self.userInfoPublisher.send(false)
                    saveUserData(UserInfo(
                        isSocialLogined: true,
                        isFirstUser: false,
                        isJoinedApp: true,
                        userNickname: nickname,
                        memberId: loadUserData()?.memberId ?? 0,
                        userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                        fcmToken: loadUserData()?.fcmToken ?? "",
                        isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false,
                        isAdmin: loadUserData()?.isAdmin ?? false
                    ))
                } else {
                    self.userInfoPublisher.send(true)
                }
            }
            .store(in: cancelBag)
    }
    
    func performKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                self?.handleKakaoLoginResult(oauthToken: oauthToken, error: error)
            }
        }
    }
    
    func performAppleLogin() {
        let appleProvider = ASAuthorizationAppleIDProvider()
        let request = appleProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    func handleKakaoLoginResult(oauthToken: OAuthToken?, error: Error?){
        guard let accessToken = oauthToken?.accessToken else { return }
        postSocialLogin(platform: .kakao, userName: nil, accessToken: accessToken)
    }
}

extension MigratedLoginViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        if let fullName = credential.fullName,
           let identifyToken = credential.identityToken {
            let userName = (fullName.familyName ?? "") + (fullName.givenName ?? "")
            if let accessToken = String(data: identifyToken, encoding: .utf8) {
                
                postSocialLogin(platform: .apple, userName: userName, accessToken: accessToken)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}
