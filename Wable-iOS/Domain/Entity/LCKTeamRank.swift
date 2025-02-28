//
//  LCKTeamRank.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - LCK 팀 랭크

struct LCKTeamRank: Hashable {
    let team: LCKTeam?
    let rank: Int
    let winCount: Int
    let defeatCount: Int
    let winningRate: Int
    let scoreGap: Int
}
