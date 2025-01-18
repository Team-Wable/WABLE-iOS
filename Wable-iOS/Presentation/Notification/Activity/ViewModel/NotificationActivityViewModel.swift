//
//  NotificationActivityViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/31/24.
//

import Combine
import UIKit

final class NotificationActivityViewModel {
    private var cursor = -1
    
    private let networkProvider: NetworkServiceType
    
    init(networkProvider: NetworkServiceType) {
        self.networkProvider = networkProvider
    }
}

// MARK: - ViewModelType

extension NotificationActivityViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let tableViewDidSelect: AnyPublisher<Int, Never>
        let tableViewDidEndDrag: AnyPublisher<Void, Never>
        let tableViewDidRefresh: AnyPublisher<Void, Never>
        let cellImageViewDidTap: AnyPublisher<Int, Never>
    }
    
    struct Output {
        let activityNotifications: AnyPublisher<[ActivityNotificationDTO], Never>
        let pushToWriteView: AnyPublisher<Void, Never>
        let homeFeed: AnyPublisher<(HomeFeedDTO, Int), Never>
        let moveToMyProfileView: AnyPublisher<Void, Never>
        let pushToOtherProfileView: AnyPublisher<Int, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let activityNotificationsSubject = CurrentValueSubject<[ActivityNotificationDTO], Never>([])
        
        input.viewWillAppear
            .handleEvents(receiveOutput: { [weak self] _ in
                Task { _ = try await self?.patchFCMBadgeAPI(badge: 0) }
            })
            .flatMap { _ -> AnyPublisher<[ActivityNotificationDTO], Never> in
                Future { [weak self] promise in
                    self?.cursor = -1
                    self?.getNotiActivityResponse(cursor: -1) { result in
                        promise(.success(result))
                    }
                }
                .eraseToAnyPublisher()
            }
            .subscribe(activityNotificationsSubject)
            .store(in: cancelBag)
        
        let selectedNotification = input.tableViewDidSelect
            .map { activityNotificationsSubject.value[$0] }
        
        let pushToWriteView = selectedNotification
            .compactMap { NotiActivityText(rawValue: $0.notificationTriggerType) }
            .filter { $0 == .actingContinue }
            .map { _ in }
            .eraseToAnyPublisher()
        
        let homeFeed = selectedNotification
            .compactMap { notification -> Int? in
                guard let notiText = NotiActivityText(rawValue: notification.notificationTriggerType),
                      ![.actingContinue, .userBan].contains(notiText)
                else {
                    return nil
                }
                
                return notification.notificationTriggerID
            }
            .flatMap { id -> AnyPublisher<(HomeFeedDTO, Int), Never> in
                return Future<(HomeFeedDTO, Int), Never> { promise in
                    NotificationAPI.shared.getFeedTopInfo(contentID: id) { [weak self] result in
                        guard let result = self?.validateResult(result) as? HomeFeedDTO else { return }
                        promise(.success((result, id)))
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        input.tableViewDidEndDrag
            .compactMap { activityNotificationsSubject.value.last?.notificationID }
            .filter { [weak self] lastNotificationID in
                activityNotificationsSubject.value.count % 15 == 0 &&
                lastNotificationID != -1 &&
                lastNotificationID != self?.cursor ?? .zero
            }
            .flatMap { lastNotificationID -> AnyPublisher<[ActivityNotificationDTO], Never> in
                Future { [weak self] promise in
                    self?.cursor = lastNotificationID
                    self?.getNotiActivityResponse(cursor: lastNotificationID) { result in
                        var notifications = activityNotificationsSubject.value
                        notifications.append(contentsOf: result)
                        promise(.success(notifications))
                    }
                }
                .eraseToAnyPublisher()
            }
            .subscribe(activityNotificationsSubject)
            .store(in: cancelBag)
        
        input.tableViewDidRefresh
            .handleEvents(receiveOutput: { [weak self] _ in
                Task { _ = try await self?.patchFCMBadgeAPI(badge: 0)}
            })
            .flatMap { _ -> AnyPublisher<[ActivityNotificationDTO], Never> in
                Future { [weak self] promise in
                    self?.cursor = -1
                    self?.getNotiActivityResponse(cursor: -1) { result in
                        promise(.success(result))
                    }
                }
                .eraseToAnyPublisher()
            }
            .subscribe(activityNotificationsSubject)
            .store(in: cancelBag)
        
        let cellImageViewDidTap = input.cellImageViewDidTap
            .share()
        
        let moveToMyProfileView = cellImageViewDidTap
            .map { activityNotificationsSubject.value[$0] }
            .filter { $0.triggerMemberID == loadUserData()?.memberId || $0.triggerMemberID == -1 }
            .map { _ in }
            .eraseToAnyPublisher()
        
        let pushToOtherProfileView = cellImageViewDidTap
            .map { activityNotificationsSubject.value[$0] }
            .filter { $0.triggerMemberID != loadUserData()?.memberId && $0.triggerMemberID != -1}
            .map { $0.triggerMemberID }
            .eraseToAnyPublisher()
        
        return Output(
            activityNotifications: activityNotificationsSubject.eraseToAnyPublisher(),
            pushToWriteView: pushToWriteView,
            homeFeed: homeFeed,
            moveToMyProfileView: moveToMyProfileView,
            pushToOtherProfileView: pushToOtherProfileView
        )
    }
}

// MARK: - Network

private extension NotificationActivityViewModel {
    func getNotiActivityResponse(cursor: Int, completion: @escaping ([ActivityNotificationDTO]) -> Void) {
        NotificationAPI.shared.getNotiActivity(cursor: cursor) { [weak self] result in
            guard let self else { return }

            guard let result = validateResult(result) as? [ActivityNotificationDTO] else {
                completion([])
                return
            }
            
            let formattedNotifications = processNotifications(result)
            completion(formattedNotifications)
        }
    }
    
    func patchFCMBadgeAPI(badge: Int) async throws -> BaseResponse<EmptyResponse>? {
        do {
            guard let accessToken = KeychainWrapper.loadToken(forKey: "accessToken") else {
                return nil
            }
            
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

// MARK: - Private Method

private extension NotificationActivityViewModel {
    func processNotifications(_ notifications: [ActivityNotificationDTO]) -> [ActivityNotificationDTO] {
        return notifications.map { notification in
            var modifiedNotification = notification
            modifiedNotification.time = notification.formattedTime()
            return modifiedNotification
        }
    }
}
