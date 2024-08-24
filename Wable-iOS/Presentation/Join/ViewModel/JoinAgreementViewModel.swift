//
//  JoinAgreementViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import Combine
import Foundation
import UIKit

final class JoinAgreementViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let networkProvider: NetworkServiceType
    
    private let pushOrPopViewController = PassthroughSubject<Int, Never>()
    private let allButtonChecked = PassthroughSubject<Bool, Never>()
    private let isEnabled = PassthroughSubject<Int, Never>()
    private let clickedButtonState = PassthroughSubject<(Int, Bool), Never>()
    
    private var isAllChecked = false
    private var isFirstChecked = false
    private var isSecondChecked = false
    private var isThirdChecked = false
    private var isFourthChecked = false
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Input {
        let backButtonTapped: AnyPublisher<Void, Never>
        let allCheckButtonTapped: AnyPublisher<Void, Never>
        let firstCheckButtonTapped: AnyPublisher<Void, Never>
        let secondCheckButtonTapped: AnyPublisher<Void, Never>
        let thirdCheckButtonTapped: AnyPublisher<Void, Never>
        let fourthCheckButtonTapped: AnyPublisher<Void, Never>
        let nextButtonTapped: AnyPublisher<UserProfileUnionRequestDTO, Never>
    }
    
    struct Output {
        let pushOrPopViewController: PassthroughSubject<Int, Never>
        let isAllcheck: PassthroughSubject<Bool, Never>
        let isEnable: PassthroughSubject<Int, Never>
        let clickedButtonState: PassthroughSubject<(Int, Bool), Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.backButtonTapped
            .sink { _ in
                self.pushOrPopViewController.send(0)
            }
            .store(in: cancelBag)
        
        input.allCheckButtonTapped
            .sink { [weak self] _ in
                // 모든 버튼 상태를 업데이트하고 신호를 보냄
                if self?.isFirstChecked == true && self?.isSecondChecked == true && self?.isThirdChecked == true && self?.isFourthChecked == true {
                    self?.isAllChecked.toggle()
                    self?.isFirstChecked = self?.isAllChecked ?? false
                    self?.isSecondChecked = self?.isAllChecked ?? false
                    self?.isThirdChecked = self?.isAllChecked ?? false
                    self?.isFourthChecked = self?.isAllChecked ?? false
                    self?.isEnabled.send(self?.isNextButtonEnabled() ?? 0)
                    self?.allButtonChecked.send(self?.isAllChecked ?? false)
                } else {
                    self?.isAllChecked = true
                    self?.isFirstChecked = self?.isAllChecked ?? false
                    self?.isSecondChecked = self?.isAllChecked ?? false
                    self?.isThirdChecked = self?.isAllChecked ?? false
                    self?.isFourthChecked = self?.isAllChecked ?? false
                    self?.isEnabled.send(self?.isNextButtonEnabled() ?? 0)
                    self?.allButtonChecked.send(self?.isAllChecked ?? false)
                }
            }
            .store(in: cancelBag)
        
        input.firstCheckButtonTapped
            .sink { [weak self] _ in
                // 첫 번째 버튼 상태를 업데이트하고 신호를 보냄
                self?.isFirstChecked.toggle()
                self?.clickedButtonState.send((1, self?.isFirstChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? 0)
            }
            .store(in: cancelBag)
        
        input.secondCheckButtonTapped
            .sink { [weak self] _ in
                // 두 번째 버튼 상태를 업데이트하고 신호를 보냄
                self?.isSecondChecked.toggle()
                self?.clickedButtonState.send((2, self?.isSecondChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? 0)
            }
            .store(in: cancelBag)
        
        input.thirdCheckButtonTapped
            .sink { [weak self] _ in
                // 세 번째 버튼 상태를 업데이트하고 신호를 보냄
                self?.isThirdChecked.toggle()
                self?.clickedButtonState.send((3, self?.isThirdChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? 0)
            }
            .store(in: cancelBag)
        
        input.fourthCheckButtonTapped
            .sink { [weak self] _ in
                // 네 번째 버튼 상태를 업데이트하고 신호를 보냄
                self?.isFourthChecked.toggle()
                self?.clickedButtonState.send((4, self?.isFourthChecked ?? false))
                self?.isEnabled.send(self?.isNextButtonEnabled() ?? 0)
            }
            .store(in: cancelBag)
        
        input.nextButtonTapped
            .sink { value in
                // 회원가입 서버통신
                Task {
                    self.patchUserInfoDataAPI(nickname: value.info?.nickname ?? "",
                                              isAlarmAllowed: value.info?.isAlarmAllowed ?? false,
                                              memberLckYears: value.info?.memberLckYears ?? 0,
                                              memberFanTeam: value.info?.memberFanTeam ?? "",
                                              memberDefaultProfileImage: value.info?.memberDefaultProfileImage ?? "",
                                              profileImage: value.file)
                    
                    self.pushOrPopViewController.send(1)
                }
                
                let fcmToken = loadUserData()?.fcmToken
                saveUserData(UserInfo(isSocialLogined: true,
                                      isFirstUser: false,
                                      isJoinedApp: true,
                                      userNickname: value.info?.nickname ?? "",
                                      memberId: loadUserData()?.memberId ?? 0,
                                      userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                                      fcmToken: fcmToken ?? "",
                                      isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false))
            }
            .store(in: cancelBag)
        
        return Output(pushOrPopViewController: pushOrPopViewController,
                      isAllcheck: allButtonChecked,
                      isEnable: isEnabled,
                      clickedButtonState: clickedButtonState)
    }
    
    private func isNextButtonEnabled() -> Int {
        let necessaryCheckCount = 3
        let allCheckCount = 4
        
        let necessaryCheckedCount = [isFirstChecked, isSecondChecked, isThirdChecked].filter { $0 }.count
        let allCheckedCount = [isFirstChecked, isSecondChecked, isThirdChecked, isFourthChecked].filter { $0 }.count
        
        if allCheckedCount == allCheckCount {
            return 0
        } else if necessaryCheckedCount >= necessaryCheckCount {
            return 1
        } else {
            return 2
        }
    }
}

// MARK: - Network

extension JoinAgreementViewModel {
    func patchUserInfoDataAPI(nickname: String, isAlarmAllowed: Bool, memberLckYears: Int, memberFanTeam: String, memberDefaultProfileImage: String, profileImage: Data?) {
        guard let url = URL(string: Config.baseURL + "/user-profile2") else { return }
        guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return }
        
        let parameters: [String: Any] = [
            "nickname": nickname,
            "isAlarmAllowed": isAlarmAllowed,
            "memberIntro": "",
            "isPushAlarmAllowed": false,
            "fcmToken": "",
            "memberLckYears": memberLckYears,
            "memberFanTeam": memberFanTeam,
            "memberDefaultProfileImage": memberDefaultProfileImage,
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        // Multipart form data 생성
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        var requestBodyData = Data()
        
        // 프로필 정보 추가
        requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
        requestBodyData.append("Content-Disposition: form-data; name=\"info\"\r\n\r\n".data(using: .utf8)!)
        requestBodyData.append(try! JSONSerialization.data(withJSONObject: parameters, options: []))
        requestBodyData.append("\r\n".data(using: .utf8)!)
        
        if memberDefaultProfileImage == "" {
            if let image = profileImage {
                // 프로필 이미지 데이터 추가
                requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
                requestBodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"dontbe.jpeg\"\r\n".data(using: .utf8)!)
                requestBodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                requestBodyData.append(image)
                requestBodyData.append("\r\n".data(using: .utf8)!)
            }
        }
        
        requestBodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // HTTP body에 데이터 설정
        request.httpBody = requestBodyData
        
        // URLSession으로 요청 보내기
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error:", error)
                return
            }
            
            // 응답 처리
            if let response = response as? HTTPURLResponse {
                print(response)
                print("Response status code:", response.statusCode)
            }
            
            if let data = data {
                // 서버 응답 데이터 처리
                print("Response data:", String(data: data, encoding: .utf8) ?? "Empty response")
            }
        }
        task.resume()
    }
}
