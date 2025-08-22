//
//  Date+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/24/25.
//

import Foundation

extension Date {
    
    // MARK: - elapsedText

    /// 현재 시간과 비교하여 상대적인 경과 시간을 한국어로 표시합니다.
    ///
    /// 이 계산 속성은 Date 인스턴스로부터 현재 시간까지의 경과 시간을 사용자 친화적인
    /// 한국어 문자열로 변환합니다. 가장 큰 시간 단위만 표시됩니다.
    ///
    /// 반환되는 시간 단위:
    /// - 년: 1년 이상 경과한 경우
    /// - 달: 1개월 이상 경과한 경우
    /// - 주: 1주 이상 경과한 경우
    /// - 일: 1일 이상 경과한 경우
    /// - 시간: 1시간 이상 경과한 경우
    /// - 분: 1분 이상 경과한 경우
    /// - "지금": 1분 미만 경과한 경우
    ///
    /// - Returns: 현재 시간으로부터의 경과 시간을 나타내는 한국어 문자열
    var elapsedText: String {
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfMonth, .month, .year],
            from: self,
            to: now
        )
        
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
