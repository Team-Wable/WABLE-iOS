//
//  NotificationInfoViewModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/31/24.
//

import Foundation
import Combine

final class NotificationInfoViewModel {
    
    // MARK: - Properties
    
    private let cancelBag = CancelBag()
    var cursor = -1
    
    // MARK: - Input
    
    let viewWillAppear = PassthroughSubject<Void, Never>()
    let paginationDidAction = PassthroughSubject<Void, Never>()
    
    // MARK: - Output
    
    let notiInfoDTO = PassthroughSubject<[InfoNotificationDTO], Never>()
    let paginationNotiInfoDTO = PassthroughSubject<[InfoNotificationDTO], Never>()
    
    // MARK: - init
    
    init() {
        transform()
    }
    
    private func transform() {
        viewWillAppear
            .sink { [weak self] in
                self?.getNotiInfoResponse(cursor: -1) { result in
                    self?.notiInfoDTO.send(result)
                }
            }
            .store(in: cancelBag)
        
        paginationDidAction
            .sink { [weak self] in
                self?.getNotiInfoResponse(cursor: self?.cursor ?? -1) { result in
                    self?.paginationNotiInfoDTO.send(result)
                }
            }
            .store(in: cancelBag)
    }
    
    private func processNotifications(_ notifications: [InfoNotificationDTO]) -> [InfoNotificationDTO] {
        return notifications.map { notification in
            var modifiedNotification = notification
            modifiedNotification.time = notification.formattedTime()
            return modifiedNotification
        }
    }
}

// MARK: - Network

extension NotificationInfoViewModel {
    
    private func getNotiInfoResponse(cursor: Int, completion: @escaping ([InfoNotificationDTO]) -> Void) {
        NotificationAPI.shared.getNotiInfo(cursor: cursor) { [weak self] result in
            guard let self = self else { return }
            guard let result = self.validateResult(result) as? [InfoNotificationDTO] else {
                completion([])
                return
            }
            
            let formattedNotifications = self.processNotifications(result)
            completion(formattedNotifications)
        }
    }
    
    private func validateResult(_ result: NetworkResult<Any>) -> Any? {
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
