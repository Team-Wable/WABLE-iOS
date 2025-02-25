//
//  NotificationRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

final class NotificationRepositoryImpl: NotificationRepository {
    private let provider: APIProvider<NotificationTargetType>
    
    init(provider: APIProvider<NotificationTargetType> = .init()) {
        self.provider = provider
    }
    
    func fetchInfoNotifications(cursor: Int) -> AnyPublisher<[InfoNotification], WableError> {
        return provider.request(
            .fetchInfoNotifications(cursor: cursor),
            for: [DTO.Response.FetchInfoNotifications].self
        )
        .map(NotificationMapper.toDomain(_:))
        .mapWableError()
    }
    
    func checkNotification() -> AnyPublisher<Void, WableError> {
        return provider.request(
            .checkNotification,
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func fetchUserNotifications(cursor: Int) -> AnyPublisher<[ActivityNotification], WableError> {
        return provider.request(
            .fetchUserNotifications(cursor: cursor),
            for: [DTO.Response.FetchUserNotifications].self
        )
        .map(NotificationMapper.toDomain(_:))
        .mapWableError()
    }
    
    func fetchUncheckedNotificationNumber() -> AnyPublisher<Int, WableError> {
        return provider.request(
            .fetchUncheckedNotificationNumber,
            for: DTO.Response.FetchNotificationNumber.self
        )
        .map { $0.notificationNumber }
        .mapWableError()
    }
}
