//
//  NotificationMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum NotificationMapper {
    static func toDomain(_ dtos: [DTO.Response.FetchInfoNotifications]) -> [InfoNotification] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return dtos.compactMap { dto in
            InfoNotification(
                id: dto.infoNotificationID,
                type: InfoNotificationType(rawValue: dto.infoNotificationType),
                time: dateFormatter.date(from: dto.time),
                imageURL: URL(string: dto.imageURL)
            )
        }
    }
    
    static func toDomain(_ dtos: [DTO.Response.FetchUserNotifications]) -> [ActivityNotification] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return dtos.compactMap { dto in
            ActivityNotification(
                id: dto.notificationID,
                triggerID: dto.notificationTriggerID,
                type: TriggerType.ActivityNotification(rawValue: dto.notificationTriggerType),
                time: dateFormatter.date(from: dto.time),
                targetContentText: dto.notificationText,
                userID: dto.memberID,
                userNickname: dto.memberNickname,
                triggerUserID: dto.triggerMemberID,
                triggerUserNickname: dto.triggerMemberNickname,
                triggerUserProfileURL: URL(string: dto.triggerMemberProfileURL),
                isChecked: dto.isNotificationChecked,
                isDeletedUser: dto.isDeleted
            )
        }
    }
}
