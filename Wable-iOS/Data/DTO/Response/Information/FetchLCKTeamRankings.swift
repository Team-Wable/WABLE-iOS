//
//  FetchLCKTeamRankings.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

extension DTO.Response {
    
    // MARK: - LCK 팀 순위 데이터
    
    struct FetchLCKTeamRankings: Decodable {
        let teamRank: Int
        let teamName: String
        let teamWin: Int
        let teamDefeat: Int
        let winningRate: Int
        let scoreDiff: Int
    }
}
