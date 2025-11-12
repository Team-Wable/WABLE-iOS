//
//  NotificationMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum NotificationMapper {
    static func toDomain(_ dtos: [DTO.Response.FetchInfoNotifications]) -> [InformationNotification] {
        return dtos.compactMap { dto in
            InformationNotification(
                id: dto.infoNotificationID,
                type: InformationNotificationType(rawValue: dto.infoNotificationType),
                time: DateFormatterHelper.date(from: dto.time, type: .fullDateTime),
                imageURL: URL(string: dto.imageURL)
            )
        }
    }
    
    static func toDomain(_ dtos: [DTO.Response.FetchUserNotifications]) -> [ActivityNotification] {
        return dtos.compactMap { dto in
            ActivityNotification(
                id: dto.notificationID,
                triggerID: dto.notificationTriggerID,
                type: TriggerType.ActivityNotification.from(dto.notificationTriggerType),
                time: DateFormatterHelper.date(from: dto.time, type: .fullDateTime),
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
