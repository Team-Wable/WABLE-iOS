//
//  FetchUserNotifications.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/16/25.
//

import Foundation

// MARK: - 유저에 해당하는 노티 리스트 조회

extension DTO.Response {
    struct FetchUserNotifications: Decodable {
        let memberID: Int
        let memberNickname: String
        let triggerMemberNickname: String
        let triggerMemberProfileURL: String
        let notificationTriggerType: String
        let time: String
        let notificationTriggerID: Int
        let notificationText: String
        let isNotificationChecked: Bool
        let isDeleted: Bool
        let notificationID: Int
        let triggerMemberID: Int
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case memberNickname, triggerMemberNickname
            case triggerMemberProfileURL = "triggerMemberProfileUrl"
            case notificationTriggerType, time
            case notificationTriggerID = "notificationTriggerId"
            case notificationText, isNotificationChecked, isDeleted
            case notificationID = "notificationId"
            case triggerMemberID = "triggerMemberId"
        }
    }
}

