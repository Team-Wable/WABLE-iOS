//
//  HomeViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import Foundation
import Combine

final class HomeViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    private let service: HomeAPI
    private let networkProvider: NetworkServiceType

    var cursor: Int = -1
    
    var feedData: [HomeFeedDTO] = []
    var feedDatas: [HomeFeedDTO] = []
    let banTargetInfo = CurrentValueSubject<(Int, String, Int), Never>((-1, "", -1))
    
    // MARK: - Input
    
    let commentButtonTapped = PassthroughSubject<Int, Never>()
    let writeButtonTapped = PassthroughSubject<Void, Never>()
    let viewWillAppear = PassthroughSubject<Void, Never>()
    let viewDidLoad = PassthroughSubject<Void, Never>()
    
    struct Input {
        let banButtonDidTapped: AnyPublisher<(Int, String, Int), Never>?
    }

    // MARK: - Output
    
    let pushViewController = PassthroughSubject<Int, Never>()
    let pushToWriteViewControllr = PassthroughSubject<Void, Never>()
    let homeFeedDTO = PassthroughSubject<[HomeFeedDTO], Never>()
    
    struct Output {
        let reloadData: PassthroughSubject<Void, Never>
    }
    
    // MARK: - init
    
    init(networkProvider: NetworkServiceType, service: HomeAPI = HomeAPI.shared) {
        self.service = service
        self.networkProvider = networkProvider
        buttonDidTapped()
        transform()
    }
    
    // MARK: - Functions
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.banButtonDidTapped?
            .flatMap { [weak self] memberID, triggerType, triggerID -> AnyPublisher<EmptyDTO?, Never> in
                guard let self else {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                return self.service.postBan(memberID: memberID, triggerType: triggerType, triggerID: triggerID)
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] _ in
                guard let self else { return }
                viewDidLoad.send()
            }
            .store(in: self.cancelBag)
        
        return Output(reloadData: viewDidLoad)
    }
    
    private func buttonDidTapped() {
        commentButtonTapped
            .sink { [weak self] index in
                self?.pushViewController.send(index)
            }
            .store(in: cancelBag)
        
        writeButtonTapped
            .sink { [weak self] in
                self?.pushToWriteViewControllr.send()
            }
            .store(in: cancelBag)
    }
    
    private func transform() {
        viewDidLoad
            .sink { [self] _ in
                Task {
                    do {
                        // 비동기 API 호출
                        try await patchUserInfoDataAPI()
                    } catch {
                        print("Error during patchUserInfoDataAPI: \(error)")
                    }
                }
            }
            .store(in: cancelBag)
        
        viewWillAppear
            .sink { [weak self] in
                let data = loadUserData()
                HomeAPI.shared.getHomeContent(cursor: self!.cursor) { result in
                    guard let result = self?.validateResult(result) as? [HomeFeedDTO] else { return }
                    
                    if self!.cursor == -1 {
                        self?.feedDatas = []
                        
                        var tempArray: [HomeFeedDTO] = []
                        
                        for content in result {
                            tempArray.append(content)
                        }
                        self?.feedDatas.append(contentsOf: tempArray)
                        self?.homeFeedDTO.send(tempArray)
                    } else {
                        var tempArray: [HomeFeedDTO] = []
                        
                        if result.isEmpty {
                            self?.cursor = -1
                        } else {
                            for content in result {
                                tempArray.append(content)
                            }
                            self?.feedDatas.append(contentsOf: tempArray)
                            self?.homeFeedDTO.send(tempArray)
                        }
                    }
                }
            }
            .store(in: cancelBag)
    }
    
    func patchUserInfoDataAPI() async throws -> Void {
        guard let url = URL(string: Config.baseURL + "v1/user-profile2") else { return }
        guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return }
        print("\(loadUserData()?.fcmToken ?? ""), \(loadUserData()?.isPushAlarmAllowed ?? false) <------------------------")
        let parameters: [String: Any] = [
            "fcmToken": loadUserData()?.fcmToken ?? "",
            "isPushAlarmAllowed": loadUserData()?.isPushAlarmAllowed ?? false
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
    
    func validateResult(_ result: NetworkResult<Any>) -> Any?{
        switch result{
        case .success(let data):
            //            print("성공했습니다.")
            //            print("⭐️⭐️⭐️⭐️⭐️⭐️")
            //            print("validateResult :\(data)")
            return data
        case .requestErr(let message):
            print(message)
        case .pathErr:
            print("path 혹은 method 오류입니다.🤯")
        case .serverErr:
            print("서버 내 오류입니다.🎯")
        case .networkFail:
            print("네트워크가 불안정합니다.💡")
        case .decodedErr:
            print("디코딩 오류가 발생했습니다.🕹️")
        case .authorizationFail(_):
            print("인증 오류가 발생했습니다. 다시 로그인해주세요🔐")
        }
        return nil
    }
}
