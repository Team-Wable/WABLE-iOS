//
//  GameSchedule.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 날짜별 경기 일정

struct GameSchedule: Hashable {
    let date: Date?
    let games: [Game]
}

// MARK: - LCK 경기

struct Game: Hashable {
    let date: Date?
    let homeTeam: LCKTeam?
    let homeScore: Int
    let awayTeam: LCKTeam?
    let awayScore: Int
    let status: GameStatus?
}
