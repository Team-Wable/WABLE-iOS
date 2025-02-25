//
//  NotificationRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

protocol NotificationRepository {
    func fetchInfoNotifications(cursor: Int) -> AnyPublisher<[InfoNotification], WableError>
    func checkNotification() -> AnyPublisher<Void, WableError>
    func fetchUserNotifications(cursor: Int) -> AnyPublisher<[ActivityNotification], WableError>
    func fetchUncheckedNotificationNumber() -> AnyPublisher<Int, WableError>
}
