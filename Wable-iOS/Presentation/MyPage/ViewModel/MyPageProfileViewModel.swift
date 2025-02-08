//
//  MyPageProfileViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/20/24.
//

import Combine
import Foundation

final class MyPageProfileViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let networkProvider: NetworkServiceType
    
    private let pushOrPopViewController = PassthroughSubject<Int, Never>()
    private let isNotDuplicated = PassthroughSubject<Bool, Never>()
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Input {
        let duplicationCheckButtonTapped: AnyPublisher<String, Never>
        let nextButtonTapped: AnyPublisher<UserProfileUnionRequestDTO, Never>
    }
    
    struct Output {
        let pushOrPopViewController: PassthroughSubject<Int, Never>
        let isEnable: PassthroughSubject<Bool, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.nextButtonTapped
            .sink { value in
                Task {
                    do {
                        try await self.patchUserInfoDataAPI(
                            nickname: value.info?.nickname ?? "",
                            isAlarmAllowed: value.info?.isAlarmAllowed ?? false,
                            memberLckYears: value.info?.memberLckYears ?? 0,
                            memberFanTeam: value.info?.memberFanTeam ?? "",
                            memberDefaultProfileImage: value.info?.memberDefaultProfileImage ?? "",
                            profileImage: value.file
                        )
                        
                        self.pushOrPopViewController.send(1)
                    }
                }
            }
            .store(in: cancelBag)
        
        input.duplicationCheckButtonTapped
            .sink { value in
                // 닉네임 중복체크 서버통신
                Task {
                    do {
                        let statusCode = try await self.getNicknameDuplicationAPI(nickname: value)?.status ?? 200
                        if statusCode == 200 {
                            self.isNotDuplicated.send(true)
                        } else {
                            self.isNotDuplicated.send(false)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            .store(in: self.cancelBag)
        
        return Output(pushOrPopViewController: pushOrPopViewController,
                      isEnable: isNotDuplicated)
    }
}

// MARK: - Network

extension MyPageProfileViewModel {
    private func getNicknameDuplicationAPI(nickname: String) async throws -> BaseResponse<EmptyResponse>? {
        do {
            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
            let data: BaseResponse<EmptyResponse>? = try await self.networkProvider.donNetwork(
                type: .get,
                baseURL: Config.baseURL + "v1/nickname-validation",
                accessToken: accessToken,
                body: EmptyBody(),
                pathVariables: ["nickname":nickname])
            return data
        } catch {
           return nil
       }
    }
    
    func patchUserInfoDataAPI(nickname: String, isAlarmAllowed: Bool, memberLckYears: Int, memberFanTeam: String, memberDefaultProfileImage: String, profileImage: Data?) async throws -> Void {
        guard let url = URL(string: Config.baseURL + "v1/user-profile2") else { return }
        guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return }

        if memberDefaultProfileImage == "" {
            print("memberDefaultProfileImage is empty")
            let parameters: [String: Any] = [
                "nickname": nickname,
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
            
            if let image = profileImage {
                // 프로필 이미지 데이터 추가
                requestBodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
                requestBodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"dontbe.jpeg\"\r\n".data(using: .utf8)!)
                requestBodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                requestBodyData.append(image)
                requestBodyData.append("\r\n".data(using: .utf8)!)
            }
            
            requestBodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            // HTTP body에 데이터 설정
            request.httpBody = requestBodyData
            
            // URLSession으로 비동기 요청 보내기
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 응답 처리
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("Response status code:", httpResponse.statusCode)
            
            if httpResponse.statusCode != 200 {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
            }
            
            guard let responseString = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
            }
            
            print("Response data:", responseString)  // 서버 응답 데이터를 처리한 후 출력
            
            return
            
        } else {
            print("memberDefaultProfileImage is not empty")
            let parameters: [String: Any] = [
                "nickname": nickname,
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
            
            requestBodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            // HTTP body에 데이터 설정
            request.httpBody = requestBodyData
            
            // URLSession으로 비동기 요청 보내기
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 응답 처리
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            print("Response status code:", httpResponse.statusCode)
            
            if httpResponse.statusCode != 200 {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed with status code \(httpResponse.statusCode)"])
            }
            
            guard let responseString = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
            }
            
            print("Response data:", responseString)  // 서버 응답 데이터를 처리한 후 출력
            
            return
        }
    }
}
