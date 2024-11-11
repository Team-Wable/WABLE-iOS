//
//  TodayMatchesDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import Foundation

// MARK: - TodayMatchesDTO

struct TodayMatchesDTO: Codable {
    private(set) var date: String
    private(set) var games: [Game]
    
    mutating func formatDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 서버에서 받은 date 형식
        dateFormatter.locale = Locale(identifier: "ko_KR") // 포맷 일관성을 위해 사용
        
        if let dateObject = dateFormatter.date(from: date) {
            // 변환할 새로운 포맷 지정
            dateFormatter.dateFormat = "MM.dd (EEE)" // "월.일 (요일)" 형식
            self.date = dateFormatter.string(from: dateObject) // date 문자열을 변환된 포맷으로 업데이트
            print("\(dateFormatter.string(from: dateObject))")
        } else {
            print("망했지예~")
        }
        
        // games 배열 내 각 게임의 시간 형식 변환
        for i in 0..<games.count {
            games[i].formatGameTime()
        }
    }
}

// MARK: - Game

struct Game: Codable, Hashable {
    private(set) var gameDate: String
    let aTeamName: String
    let aTeamScore: Int
    let bTeamName: String
    let bTeamScore: Int
    let gameStatus: String
    
    mutating func formatGameTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // 서버에서 받은 gameDate 형식
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 포맷 일관성을 위해 사용
        
        if let dateObject = dateFormatter.date(from: gameDate) {
            // 변환할 새로운 포맷 지정
            dateFormatter.dateFormat = "HH:mm" // "시간:분" 형식
            self.gameDate = dateFormatter.string(from: dateObject) // gameDate 문자열을 변환된 포맷으로 업데이트
        } else {
            print("^^~")
        }
    }
}
