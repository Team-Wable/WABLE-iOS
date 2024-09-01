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
    var time: String
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

extension ActivityNotificationDTO {
    func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current  // 현재 시스템 시간대로 설정
        
        guard let postDate = dateFormatter.date(from: time) else {
            return "잘못된 날짜 형식"
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // 모든 시간 단위의 차이를 계산
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfMonth, .month, .year], from: postDate, to: now)

        // 각 시간 단위에 따른 차이를 계산하여 문자열을 반환
        if let years = components.year, years > 0 {
            return "\(years)년 전"
        } else if let months = components.month, months > 0 {
            return "\(months)달 전"
        } else if let weeks = components.weekOfMonth, weeks > 0 {
            return "\(weeks)주 전"
        } else if let days = components.day, days > 0 {
            return "\(days)일 전"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)시간 전"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)분 전"
        } else {
            return "지금"
        }
    }
}
