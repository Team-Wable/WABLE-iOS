//
//  NotificationActivityViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/31/24.
//

import Combine
import UIKit

final class NotificationActivityViewModel {
    
    // MARK: - Properties
    
    private let cancelBag = CancelBag()
    var cursor = -1
    private let networkProvider: NetworkServiceType
    
    // MARK: - Input
    
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let viewWillAppear = PassthroughSubject<Void, Never>()
    let paginationDidAction = PassthroughSubject<Void, Never>()
    let notiCellDidTapped = PassthroughSubject<Int, Never>()
    let writeFeedCellDidTapped = PassthroughSubject<Void, Never>()
    
    // MARK: - Output
    
    let notiActivityDTO = PassthroughSubject<[ActivityNotificationDTO], Never>()
    let paginationNotiActivityDTO = PassthroughSubject<[ActivityNotificationDTO], Never>()
    let homeFeedTopInfoDTO = PassthroughSubject<(HomeFeedDTO, Int), Never>()
    let pushToWriteViewController = PassthroughSubject<Void, Never>()
    
    // MARK: - init
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
        self.transform()
    }
    
    // MARK: - Functions
    
    private func transform() {
        viewDidLoad
            .sink { [self] _ in
                Task {
                    let cleanBadgeState = try await self.patchFCMBadgeAPI(badge: 0)
                }
            }
            .store(in: self.cancelBag)
        
        viewWillAppear
            .sink { [self] _ in
                Task {
                    let cleanBadgeState = try await self.patchFCMBadgeAPI(badge: 0)
                }
                
                self.getNotiActivityResponse(cursor: -1) { result in
                    self.notiActivityDTO.send(result)
                }
            }
            .store(in: cancelBag)
        
        paginationDidAction
            .sink { [weak self] in
                self?.getNotiActivityResponse(cursor: self?.cursor ?? -1) { result in
                    self?.paginationNotiActivityDTO.send(result)
                }
            }
            .store(in: cancelBag)
        
        notiCellDidTapped
            .sink { [weak self] contentID in
                NotificationAPI.shared.getFeedTopInfo(contentID: contentID) { result in
                    guard let result = self?.validateResult(result) as? HomeFeedDTO else { return }
                    self?.homeFeedTopInfoDTO.send((result,contentID))
                }
            }
            .store(in: cancelBag)
        
        writeFeedCellDidTapped
            .sink { [weak self] in
                self?.pushToWriteViewController.send()
            }
            .store(in: cancelBag)
        
    }
    
    private func processNotifications(_ notifications: [ActivityNotificationDTO]) -> [ActivityNotificationDTO] {
        return notifications.map { notification in
            var modifiedNotification = notification
            modifiedNotification.time = notification.formattedTime()
            return modifiedNotification
        }
    }
}

// MARK: - Network

extension NotificationActivityViewModel {
    
    private func getNotiActivityResponse(cursor: Int, completion: @escaping ([ActivityNotificationDTO]) -> Void) {
        NotificationAPI.shared.getNotiActivity(cursor: cursor) { [weak self] result in
            guard let self = self else { return }
            print("result: \(result)")

            guard let result = self.validateResult(result) as? [ActivityNotificationDTO] else {
                completion([])
                return
            }
            
            let formattedNotifications = self.processNotifications(result)
            completion(formattedNotifications)
        }
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
            print ("👻👻👻👻👻FCMBadge 개수 수정 완료👻👻👻👻👻")
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }

            return data
        } catch {
            return nil
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
