//
//  Notification.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 활동 푸쉬 알림

struct ActivityNotification {
    let id: Int
    let triggerID: Int
    let type: TriggerType?
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

extension ActivityNotification {
    enum TriggerType: String {
        case contentLike = "contentLiked"
        case commentLike = "commentLiked"
        case comment = "comment"
        case contentGhost = "contentGhost"
        case commentGhost = "commentGhost"
        case beGhost = "beGhost"
        case actingContinue = "actingContinue"
        case userBan = "userBan"
        case popularWriter = "popularWriter"
        case popularContent = "popularContent"
        case childComment = "childComment"
        case childCommentLike = "childCommentLiked"
    }
}

// MARK: - 정보 푸쉬 알림

struct InfoNotification {
    let id: Int
    let type: NotificationType?
    let time: Date?
    let imageURL: URL?
}

extension InfoNotification {
    enum NotificationType: String {
        case gameDone = "GAMEDONE"
        case gameStart = "GAMESTART"
        case weekDone = "WEEKDONE"
    }
}
