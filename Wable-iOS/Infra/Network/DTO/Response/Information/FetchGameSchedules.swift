//
//  FetchGameSchedules.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

extension DTO.Response {
    
    // MARK: - 날짜별 경기 일정
    
    struct FetchGameSchedules: Decodable {
        let date: String
        let games: [Game]
    }
    
    // MARK: - 개별 경기 정보
    
    struct Game: Decodable {
        let gameDate: String
        let aTeamName: String
        let aTeamScore: Int
        let bTeamName: String
        let bTeamScore: Int
        let gameStatus: String
    }
}
