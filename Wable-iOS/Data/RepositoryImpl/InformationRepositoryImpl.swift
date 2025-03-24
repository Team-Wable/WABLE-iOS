//
//  InformationRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

final class InformationRepositoryImpl: InformationRepository {
    private let provider: APIProvider<InformationTargetType>
    
    init(provider: APIProvider<InformationTargetType> = .init()) {
        self.provider = provider
    }
    
    func fetchGameSchedules() -> AnyPublisher<[GameSchedule], WableError> {
        return provider.request(
            .fetchGameSchedules,
            for: [DTO.Response.FetchGameSchedules].self
        )
        .map(InformationMapper.toDomain(_:))
        .mapWableError()
    }
    
    func fetchGameCategory() -> AnyPublisher<String, WableError> {
        return provider.request(
            .fetchGameCategory,
            for: DTO.Response.FetchGameCategory.self
        )
        .map { $0.lckGameType }
        .mapWableError()
    }
    
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError> {
        return provider.request(
            .fetchTeamRanks,
            for: [DTO.Response.FetchLCKTeamRankings].self
        )
        .map(InformationMapper.toDomain(_:))
        .mapWableError()
    }
    
    func fetchNewsNoticeNumber() -> AnyPublisher<(newsNumber: Int, noticeNumber: Int), WableError> {
        return provider.request(
            .fetchNewsNoticeNumber,
            for: DTO.Response.FetchNewsNoticeNumber.self
        )
        .map { ($0.newsNumber, $0.noticeNumber) }
        .mapWableError()
    }
    
    func fetchNews(cursor: Int) -> AnyPublisher<[Announcement], WableError> {
        return provider.request(
            .fetchNews(cursor: cursor),
            for: [DTO.Response.FetchNews].self
        )
        .map(InformationMapper.toDomain(_:))
        .mapWableError()
    }
    
    func fetchNotice(cursor: Int) -> AnyPublisher<[Announcement], WableError> {
        return provider.request(
            .fetchNotices(cursor: cursor),
            for: [DTO.Response.FetchNotices].self
        )
        .map(InformationMapper.toDomain(_:))
        .mapWableError()
    }
}

struct MockInformationRepositoryImpl: InformationRepository {
    func fetchGameCategory() -> AnyPublisher<String, WableError> {
        return .just("2025 LCK SPRING")
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchGameSchedules() -> AnyPublisher<[GameSchedule], WableError> {
        let mockGameSchedules: [GameSchedule] = [
            GameSchedule(date: Date(), games: [
                Game(date: Date(), homeTeam: .t1, homeScore: 1, awayTeam: .gen, awayScore: 2, status: .scheduled),
                Game(date: Date(), homeTeam: .hle, homeScore: 3, awayTeam: .dk, awayScore: 4, status: .scheduled),
                Game(date: Date(), homeTeam: .kt, homeScore: 5, awayTeam: .ns, awayScore: 6, status: .scheduled),
                Game(date: Date(), homeTeam: .drx, homeScore: 7, awayTeam: .bro, awayScore: 8, status: .scheduled),
                Game(date: Date(), homeTeam: .bfx, homeScore: 9, awayTeam: .dnf, awayScore: 10, status: .scheduled)
            ]),
            GameSchedule(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, games: [
                Game(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, homeTeam: .t1, homeScore: 1, awayTeam: .gen, awayScore: 2, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, homeTeam: .hle, homeScore: 3, awayTeam: .dk, awayScore: 4, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, homeTeam: .kt, homeScore: 5, awayTeam: .ns, awayScore: 6, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, homeTeam: .drx, homeScore: 7, awayTeam: .bro, awayScore: 8, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, homeTeam: .bfx, homeScore: 9, awayTeam: .dnf, awayScore: 10, status: .scheduled)
            ]),
            GameSchedule(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, games: [
                Game(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, homeTeam: .t1, homeScore: 1, awayTeam: .gen, awayScore: 2, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, homeTeam: .hle, homeScore: 3, awayTeam: .dk, awayScore: 4, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, homeTeam: .kt, homeScore: 5, awayTeam: .ns, awayScore: 6, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, homeTeam: .drx, homeScore: 7, awayTeam: .bro, awayScore: 8, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, homeTeam: .bfx, homeScore: 9, awayTeam: .dnf, awayScore: 10, status: .scheduled)
            ]),
            GameSchedule(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, games: [
                Game(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, homeTeam: .t1, homeScore: 1, awayTeam: .gen, awayScore: 2, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, homeTeam: .hle, homeScore: 3, awayTeam: .dk, awayScore: 4, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, homeTeam: .kt, homeScore: 5, awayTeam: .ns, awayScore: 6, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, homeTeam: .drx, homeScore: 7, awayTeam: .bro, awayScore: 8, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, homeTeam: .bfx, homeScore: 9, awayTeam: .dnf, awayScore: 10, status: .scheduled)
            ]),
            GameSchedule(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, games: [
                Game(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, homeTeam: .t1, homeScore: 1, awayTeam: .gen, awayScore: 2, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, homeTeam: .hle, homeScore: 3, awayTeam: .dk, awayScore: 4, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, homeTeam: .kt, homeScore: 5, awayTeam: .ns, awayScore: 6, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, homeTeam: .drx, homeScore: 7, awayTeam: .bro, awayScore: 8, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!, homeTeam: .bfx, homeScore: 9, awayTeam: .dnf, awayScore: 10, status: .scheduled)
            ]),
            GameSchedule(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, games: [
                Game(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, homeTeam: .t1, homeScore: 1, awayTeam: .gen, awayScore: 2, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, homeTeam: .hle, homeScore: 3, awayTeam: .dk, awayScore: 4, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, homeTeam: .kt, homeScore: 5, awayTeam: .ns, awayScore: 6, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, homeTeam: .drx, homeScore: 7, awayTeam: .bro, awayScore: 8, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, homeTeam: .bfx, homeScore: 9, awayTeam: .dnf, awayScore: 10, status: .scheduled)
            ]),
            GameSchedule(date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, games: [
                Game(date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, homeTeam: .t1, homeScore: 1, awayTeam: .gen, awayScore: 2, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, homeTeam: .hle, homeScore: 3, awayTeam: .dk, awayScore: 4, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, homeTeam: .kt, homeScore: 5, awayTeam: .ns, awayScore: 6, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, homeTeam: .drx, homeScore: 7, awayTeam: .bro, awayScore: 8, status: .scheduled),
                Game(date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, homeTeam: .bfx, homeScore: 9, awayTeam: .dnf, awayScore: 10, status: .scheduled)
            ])
        ]

        return .just(mockGameSchedules)
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError> {
        let mockLCKTeamRanks: [LCKTeamRank] = [
            LCKTeamRank(team: .t1, rank: 1, winCount: 15, defeatCount: 3, winningRate: 83, scoreGap: +20),
            LCKTeamRank(team: .gen, rank: 2, winCount: 14, defeatCount: 4, winningRate: 78, scoreGap: +18),
            LCKTeamRank(team: .dk, rank: 3, winCount: 12, defeatCount: 6, winningRate: 67, scoreGap: +12),
            LCKTeamRank(team: .hle, rank: 4, winCount: 11, defeatCount: 7, winningRate: 61, scoreGap: +9),
            LCKTeamRank(team: .kt, rank: 5, winCount: 10, defeatCount: 8, winningRate: 56, scoreGap: +5),
            LCKTeamRank(team: .drx, rank: 6, winCount: 8, defeatCount: 10, winningRate: 44, scoreGap: -2),
            LCKTeamRank(team: .ns, rank: 7, winCount: 7, defeatCount: 11, winningRate: 39, scoreGap: -5),
            LCKTeamRank(team: .bro, rank: 8, winCount: 5, defeatCount: 13, winningRate: 28, scoreGap: -10),
            LCKTeamRank(team: .bfx, rank: 9, winCount: 4, defeatCount: 14, winningRate: 22, scoreGap: -15),
            LCKTeamRank(team: .dnf, rank: 10, winCount: 3, defeatCount: 15, winningRate: 17, scoreGap: -18)
        ]

        return .just(mockLCKTeamRanks)
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchNews(cursor: Int) -> AnyPublisher<[Announcement], WableError> {
        let range: ClosedRange<Int>
        
        switch cursor {
        case -1:
            range = 1...15
        case 15:
            range = 16...30
        case 30:
            range = 31...33
        default:
            return .just([])
        }
        
        return .just(range.map { id in
            Announcement(
                id: id,
                title: "공지사항 \(id)",
                imageURL: URL(string: Constant.imageURLText),
                text: "이것은 공지사항 \(id)입니다.",
                createdDate: Calendar.current.date(byAdding: .day, value: -id, to: Date())
            )
        })
        .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func fetchNotice(cursor: Int) -> AnyPublisher<[Announcement], WableError> {
        return .fail(.networkError)
    }
    
    func fetchNewsNoticeNumber() -> AnyPublisher<(newsNumber: Int, noticeNumber: Int), WableError> {
        return .fail(.networkError)
    }
    
    private var randomDelaySecond: Double { .random(in: 0.3...1.0) }
    
    private enum Constant {
        static let imageURLText: String = "https://private-user-images.githubusercontent.com/98076050/396859961-b02e03eb-6f64-4a44-88e2-88badb3d3b10.jpg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDI4MzUxNzYsIm5iZiI6MTc0MjgzNDg3NiwicGF0aCI6Ii85ODA3NjA1MC8zOTY4NTk5NjEtYjAyZTAzZWItNmY2NC00YTQ0LTg4ZTItODhiYWRiM2QzYjEwLmpwZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTAzMjQlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwMzI0VDE2NDc1NlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWQzZWE1OTlhNDFhYzk5MGYwYWZiNDg4MGMwNDllOTMzNGE5MTFlZGQ2NDY5MmViZTgzZDhiMTM3YWE1ODY5NmUmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.LO8fsMErFZAKahjnYeQk8nHpzc3Cpug0n_-6fq3R4K4"
    }
}
