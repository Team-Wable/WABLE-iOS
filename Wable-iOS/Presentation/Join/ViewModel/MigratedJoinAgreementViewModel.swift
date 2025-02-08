//
//  MigratedJoinAgreementViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/8/25.
//

import Combine
import Foundation
import UIKit

final class MigratedJoinAgreementViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let service: JoinAPI
    private let userInfo: UserInfoBuilder
    private let allButtonChecked = PassthroughSubject<Bool, Never>()
    private let isEnabled = PassthroughSubject<Int, Never>()
    private let clickedButtonState = PassthroughSubject<(Int, Bool), Never>()
    
    @Published private var isAllChecked = false
    @Published private var isFirstChecked = false
    @Published private var isSecondChecked = false
    @Published private var isThirdChecked = false
    @Published private var isFourthChecked = false
    
    init(
        service: JoinAPI = JoinAPI.shared,
        userInfo: UserInfoBuilder
    ) {
        self.service = service
        self.userInfo = userInfo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Input {
        let allCheckButtonTapped: AnyPublisher<Void, Never>
        let firstCheckButtonTapped: AnyPublisher<Void, Never>
        let secondCheckButtonTapped: AnyPublisher<Void, Never>
        let thirdCheckButtonTapped: AnyPublisher<Void, Never>
        let fourthCheckButtonTapped: AnyPublisher<Void, Never>
        let nextButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let nextButtonDidTapped: AnyPublisher<Void, Never>
        let isAllChecked: AnyPublisher<Bool, Never> // 전체 동의 체크 상태
        let isNextButtonEnabled: AnyPublisher<Bool, Never> // 다음 버튼 활성화 여부
        let individualButtonStates: AnyPublisher<[Bool], Never> // 개별 버튼 상태
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.firstCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                owner.isFirstChecked.toggle()
            }
            .store(in: cancelBag)
        
        input.secondCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                owner.isSecondChecked.toggle()
            }
            .store(in: cancelBag)
        
        input.thirdCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                owner.isThirdChecked.toggle()
            }
            .store(in: cancelBag)
        
        input.fourthCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                owner.isFourthChecked.toggle()
                owner.userInfo.setIsAlarmAllowed(owner.isFourthChecked)
            }
            .store(in: cancelBag)
        
        input.allCheckButtonTapped
            .withUnretained(self)
            .sink { owner, _ in
                let newState = !(owner.isFirstChecked && owner.isSecondChecked && owner.isThirdChecked && owner.isFourthChecked)
                owner.isFirstChecked = newState
                owner.isSecondChecked = newState
                owner.isThirdChecked = newState
                owner.isFourthChecked = newState
            }
            .store(in: cancelBag)
        
        let individualButtonStates = Publishers.CombineLatest4($isFirstChecked, $isSecondChecked, $isThirdChecked, $isFourthChecked)
            .map { [$0, $1, $2, $3] }
            .eraseToAnyPublisher()
        
        let isAllChecked = individualButtonStates
            .map { $0.allSatisfy { $0 } } //allSatisfy를 통해 모든 값이 true인지 확인. 하나라도 다르면 false리턴
            .eraseToAnyPublisher()
        
        let isNextButtonEnabled = Publishers.CombineLatest3($isFirstChecked, $isSecondChecked, $isThirdChecked)
            .map { $0 && $1 && $2 }
            .eraseToAnyPublisher()
        
        let nextButtonDidTapped = input.nextButtonTapped
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Void, Never> in
                owner.userInfo
                    .setFcmToken(loadUserData()?.fcmToken)
                    .setIsPushAlarmAllowed(loadUserData()?.isPushAlarmAllowed)
                    .setMemberIntro("")
                
                return owner.service.patchUserProfile(requestBody: owner.userInfo.build())
                    .mapWableNetworkError()
                    .replaceError(with: nil)
                    .map { _ in }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
            
        
        return Output(
            nextButtonDidTapped: nextButtonDidTapped,
            isAllChecked: isAllChecked,
            isNextButtonEnabled: isNextButtonEnabled,
            individualButtonStates: individualButtonStates
        )
    }
}

//// MARK: - Network
//
//extension MigratedJoinAgreementViewModel {
//    func patchUserInfoDataAPI(nickname: String, isAlarmAllowed: Bool, memberLckYears: Int, memberFanTeam: String, memberDefaultProfileImage: String, profileImage: Data?) async throws -> Void {
//        guard let url = URL(string: Config.baseURL + "v1/user-profile2") else { return }
//        guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return }
//        
//        print("accessToken: \(accessToken)")
//        
//        let parameters: [String: Any] = [
//            "nickname": nickname,
//            "isAlarmAllowed": isAlarmAllowed,
//            "memberIntro": "",
//            "isPushAlarmAllowed": loadUserData()?.isPushAlarmAllowed ?? false,
//            "fcmToken": loadUserData()?.fcmToken ?? "",
//            "memberLckYears": memberLckYears,
//            "memberFanTeam": memberFanTeam,
//            "memberDefaultProfileImage": memberDefaultProfileImage == "" ? "GREEN" : memberDefaultProfileImage,
//        ]
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "PATCH"
//        
//        // Multipart form data 생성
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//        var requestBodyData = Data()
//        
//        // 프로필 정보 추가
//        requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
//        requestBodyData.append("Content-Disposition: form-data; name=\"info\"\r\n\r\n".data(using: .utf8)!)
//        requestBodyData.append(try! JSONSerialization.data(withJSONObject: parameters, options: []))
//        requestBodyData.append("\r\n".data(using: .utf8)!)
//        
//        requestBodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        
//        // HTTP body에 데이터 설정
//        request.httpBody = requestBodyData
//        
//        // URLSession으로 비동기 요청 보내기
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        // 응답 처리
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
//        }
//        
//        print("Response status code:", httpResponse.statusCode)
//        
//        if httpResponse.statusCode != 200 {
//            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
//        }
//        
//        guard let responseString = String(data: data, encoding: .utf8) else {
//            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
//        }
//        
//        print("Response data:", responseString)  // 서버 응답 데이터를 처리한 후 출력
//        
//        if let image = profileImage {
//            Task {
//                do {
//                    try await self.patchUserProfileDataAPI(profileImage: image)
//                }
//            }
//        }
//            return
//    }
//    
//    func patchUserProfileDataAPI(profileImage: Data?) async throws -> Void {
//        guard let url = URL(string: Config.baseURL + "v1/user-profile2") else { return }
//        guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "PATCH"
//        
//        // Multipart form data 생성
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//        var requestBodyData = Data()
//        
//        // 이미지 데이터 추가
//        if let image = profileImage {
//            requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
//            requestBodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"dontbe.jpeg\"\r\n".data(using: .utf8)!)
//            requestBodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//            requestBodyData.append(image)
//            requestBodyData.append("\r\n".data(using: .utf8)!)
//        }
//        
//        // 빈 info 필드 추가
//        let emptyInfo: [String: Any] = [:]  // 빈 JSON 객체
//        requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
//        requestBodyData.append("Content-Disposition: form-data; name=\"info\"\r\n".data(using: .utf8)!)
//        requestBodyData.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
//        let jsonData = try! JSONSerialization.data(withJSONObject: emptyInfo, options: [])
//        requestBodyData.append(jsonData)
//        requestBodyData.append("\r\n".data(using: .utf8)!)
//        
//        requestBodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        
//        // HTTP body에 데이터 설정
//        request.httpBody = requestBodyData
//        
//        // URLSession으로 비동기 요청 보내기
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        // 응답 처리
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
//        }
//        
//        print("Response status code:", httpResponse.statusCode)
//        
//        if httpResponse.statusCode != 200 {
//            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
//        }
//        
//        guard let responseString = String(data: data, encoding: .utf8) else {
//            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
//        }
//        
//        print("Response data:", responseString)  // 서버 응답 데이터를 처리한 후 출력
//        
//        return
//    }
//
//}
