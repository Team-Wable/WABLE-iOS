//
//  NoticeTimeFormatter.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/26/24.
//

import Foundation

struct NoticeTimeFormatter {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    func formattedNews(news: [NoticeDTO]) -> [NoticeDTO] {
        return news.map { formattedNews(news: $0) }
    }
    
    func formattedNews(news: NoticeDTO) -> NoticeDTO {
        return NoticeDTO(
            id: news.id,
            title: news.title,
            text: news.text,
            imageURLString: news.imageURLString,
            time: timeElapsedString(from: news.time)
        )
    }
    
    private func timeElapsedString(from time: String) -> String {
        guard let postDate = dateFormatter.date(from: time) else {
            return "time"
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfMonth, .month, .year],
            from: postDate,
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
