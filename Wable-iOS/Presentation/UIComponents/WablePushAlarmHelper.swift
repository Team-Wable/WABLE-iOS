//
//  WablePushAlarmHelper.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 9/18/24.
//

import UIKit

struct FCMBadgeDTO: Encodable {
    let fcmBadge: Int
}


final class WablePushAlarmHelper {
    
    private var contentID = Int()
    private let networkProvider: NetworkServiceType
    
    init(contentID: Int, networkProvider: NetworkServiceType) {
        self.contentID = contentID
        self.networkProvider = networkProvider
    }
    
    func start() {
        load()
    }
    
    private func load() {
        NotificationAPI.shared.getFeedTopInfo(contentID: contentID) { result in
            guard let result = self.validateResult(result) as? HomeFeedDTO else { return }
            if let window = UIApplication.shared.windows.first {
                if let rootViewController = window.rootViewController as? UINavigationController {
                    let targetViewController = FeedDetailViewController(viewModel: FeedDetailViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
                    // 데이터 전달
                    targetViewController.getFeedData(data: result)
                    targetViewController.viewModel.contentIDSubject.send(Int(self.contentID))
                    rootViewController.pushViewController(targetViewController, animated: true)
                }
            }
        }
    }
    
    func checkUserLoginState() {
        
    }
    
    func patchFCMBadgeAPI(badge: Int) async throws -> BaseResponse<EmptyResponse>? {
        do {
            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else { return nil }
            let resquestDTO = FCMBadgeDTO(fcmBadge: badge)
            let data: BaseResponse<EmptyResponse>? = try await self.networkProvider.donNetwork(
                type: .patch,
                baseURL: Config.baseURL + "v1/fcmbadge",
                accessToken: accessToken,
                body: resquestDTO,
                pathVariables: ["": ""])
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = badge
            }
            print ("👻👻👻👻👻FCMBadge 개수 수정 완료👻👻👻👻👻")
            return data
        }
    }
    private func validateResult(_ result: NetworkResult<Any>) -> Any?{
        switch result{
        case .success(let data):
            print("성공했습니다.")
            print("⭐️⭐️⭐️⭐️⭐️⭐️")
            print(data)
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
