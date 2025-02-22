//
//  LCKTeamRank.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - LCK 팀 랭크

struct LCKTeamRank {
    let team: LCKTeam?
    let rankNumber: Int
    let winNumber: Int
    let defeatNumber: Int
    let winningRate: Int
    let scoreGap: Int
}
