//
//  InformationMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum InformationMapper {
    static func toDomain(_ dtos: [DTO.Response.FetchGameSchedules]) -> [GameSchedule] {
        let gameDateFormatter = DateFormatter()
        gameDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        gameDateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        let scheduleDateFormatter = DateFormatter()
        scheduleDateFormatter.dateFormat = "yyyy-MM-dd"
        scheduleDateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return dtos.compactMap { dto in
            let games = dto.games.compactMap { gameDTO in
                Game(
                    date: gameDateFormatter.date(from: gameDTO.gameDate),
                    homeTeam: LCKTeam(rawValue: gameDTO.aTeamName),
                    homeScore: gameDTO.aTeamScore,
                    awayTeam: LCKTeam(rawValue: gameDTO.bTeamName),
                    awayScore: gameDTO.bTeamScore,
                    status: GameStatus(rawValue: gameDTO.gameStatus.uppercased())
                )
            }
            return GameSchedule(
                date: scheduleDateFormatter.date(from: dto.date),
                games: games
            )
        }
    }
    
    static func toDomain(_ dtos: [DTO.Response.FetchLCKTeamRankings]) -> [LCKTeamRank] {
        return dtos.compactMap { dto in
            LCKTeamRank(
                team: LCKTeam(rawValue: dto.teamName),
                rank: dto.teamRank,
                winCount: dto.teamWin,
                defeatCount: dto.teamDefeat,
                winningRate: dto.winningRate,
                scoreGap: dto.scoreDiff
            )
        }
    }
    
    static func toDomain(_ dtos: [DTO.Response.FetchNews]) -> [Announcement] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return dtos.compactMap { dto in
            Announcement(
                id: dto.newsID,
                title: dto.newsTitle,
                imageURL: URL(string: dto.newsImageURL),
                text: dto.newsText,
                createdDate: dateFormatter.date(from: dto.time)
            )
        }
    }
    
    static func toDomain(_ dtos: [DTO.Response.FetchNotices]) -> [Announcement] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")

        return dtos.compactMap { dto in
            Announcement(
                id: dto.noticeID,
                title: dto.noticeTitle,
                imageURL: URL(string: dto.noticeImageURL),
                text: dto.noticeText,
                createdDate: dateFormatter.date(from: dto.time)
            )
        }
    }
}
