//
//  TodayMatchesDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import Foundation

// MARK: - TodayMatchesDTO

struct TodayMatchesDTO: Codable {
    let date: String
    let games: [Game]
}

// MARK: - Game

struct Game: Codable, Hashable {
    let gameDate: String
    let aTeamName: String
    let aTeamScore: Int
    let bTeamName: String
    let bTeamScore: Int
    let gameStatus: String
}
