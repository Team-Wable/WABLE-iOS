//
//  Notification.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 활동 푸쉬 알림

struct ActivityNotification: Identifiable, Hashable {
    let id: Int
    let triggerID: Int
    let type: TriggerType.ActivityNotification?
    let time: Date?
    let text: String
    let userID: Int
    let userNickname: String
    let triggerUserID: Int
    let triggerUserNickname: String
    let triggerUserProfileURL: URL?
    let isChecked: Bool
    let isDeletedUser: Bool
}

// MARK: - 정보 푸쉬 알림

struct InfoNotification: Identifiable, Hashable {
    let id: Int
    let type: InfoNotificationType?
    let time: Date?
    let imageURL: URL?
}
