//
//  LCKTeamRankDTO.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/22/24.
//

import Foundation

struct LCKTeamRankDTO: Codable {
    let teamRankNumber: Int
    let teamName: String
    let teamWinCount: Int
    let teamDefeatCount: Int
    let winningRate: Int
    let scoreDiff: Int
    
    enum CodingKeys: String, CodingKey {
        case teamRankNumber = "teamRank"
        case teamName
        case teamWinCount = "teamWin"
        case teamDefeatCount = "teamDefeat"
        case winningRate
        case scoreDiff
    }
}
