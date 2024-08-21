//
//  ActivityNotificationDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/21/24.
//

import UIKit

struct ActivityNotificationDTO: Codable {
    let memberID: Int
    let memberNickname, triggerMemberNickname, triggerMemberProfileURL, notificationTriggerType: String
    let time: String
    let notificationTriggerID: Int
    let notificationText: String
    let isNotificationChecked, isDeleted: Bool
    let notificationID, triggerMemberID: Int

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

