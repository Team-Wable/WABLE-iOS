//
//  InformationMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum InformationMapper {
    static func toDomain(_ dtos: [DTO.Response.FetchGameSchedules]) -> [GameSchedule] {
        return dtos.compactMap { dto in
            let games = dto.games.compactMap { gameDTO in
                Game(
                    date: DateFormatterHelper.date(from: gameDTO.gameDate, type: .dateTimeWithMinute),
                    homeTeam: gameDTO.aTeamName,
                    homeScore: gameDTO.aTeamScore,
                    awayTeam: gameDTO.bTeamName,
                    awayScore: gameDTO.bTeamScore,
                    status: GameStatus(rawValue: gameDTO.gameStatus.uppercased())
                )
            }
            return GameSchedule(
                date: DateFormatterHelper.date(from: dto.date, type: .dashSeparatedDate),
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
        return dtos.compactMap { dto in
            Announcement(
                id: dto.newsID,
                title: dto.newsTitle,
                imageURL: URL(string: dto.newsImageURL ?? ""),
                text: dto.newsText,
                createdDate: DateFormatterHelper.date(from: dto.time, type: .fullDateTime)
            )
        }
    }
    
    static func toDomain(_ dtos: [DTO.Response.FetchNotices]) -> [Announcement] {
        return dtos.compactMap { dto in
            Announcement(
                id: dto.noticeID,
                title: dto.noticeTitle,
                imageURL: URL(string: dto.noticeImageURL ?? ""),
                text: dto.noticeText,
                createdDate: DateFormatterHelper.date(from: dto.time, type: .fullDateTime)
            )
        }
    }

    static func toDomain(_ dtos: [DTO.Response.FetchCurationList]) -> [Curation] {
        return dtos.compactMap { dto in
            guard let url = URL(string: dto.urlString),
                  let time = DateFormatterHelper.date(from: dto.createdAt, type: .fullDateTime)
            else {
                WableLogger.log("Failed to map Curation DTO to Domain", for: .debug)
                return nil
            }
            
            return Curation(
                id: dto.id,
                title: dto.title ?? "제목 없음",
                time: time,
                siteURL: url,
                thumbnailURL: dto.thumbnailURLString.flatMap { URL(string: $0) }
            )
        }
    }
}
