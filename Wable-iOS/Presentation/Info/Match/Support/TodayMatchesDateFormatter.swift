//
//  TodayMatchesDateFormatter.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/27/24.
//

import Foundation

struct TodayMatchesDateFormmatter {
    private let inputFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter
    }()
    
    private let outputFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd (EEE)"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter
    }()
    
    private let gameFormatter = GameDateFormatter()
    
    func formatting(_ matches: [TodayMatchesDTO]) -> [TodayMatchesDTO] {
        matches.map { formatting($0) }
    }
    
    func formatting(_ match: TodayMatchesDTO) -> TodayMatchesDTO {
        TodayMatchesDTO(
            date: monthAndDay(match.date),
            games: gameFormatter.formatting(match.games)
        )
    }
    
    private func monthAndDay(_ dateString: String) -> String {
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        return outputFormatter.string(from: date)
    }
}

struct GameDateFormatter {
    private let inputFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()
    
    private let outputFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    func formatting(_ games: [Game]) -> [Game] {
        games.map { formatting($0) }
    }
    
    func formatting(_ game: Game) -> Game {
        Game(
            gameDate: hourAndMinute(game.gameDate),
            aTeamName: game.aTeamName,
            aTeamScore: game.aTeamScore,
            bTeamName: game.bTeamName,
            bTeamScore: game.bTeamScore,
            gameStatus: game.gameStatus
        )
    }
    
    private func hourAndMinute(_ dateString: String) -> String {
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        return outputFormatter.string(from: date)
    }
}
