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
        if let window = UIApplication.shared.windows.first {
            if let rootViewController = window.rootViewController as? UINavigationController {
                let targetViewController = FeedDetailViewController(viewModel: FeedDetailViewModel(networkProvider: NetworkService()), likeViewModel: LikeViewModel(networkProvider: NetworkService()))
                // 데이터 전달
                targetViewController.contentId = Int(self.contentID ?? 0)
                rootViewController.pushViewController(targetViewController, animated: true)
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
}
