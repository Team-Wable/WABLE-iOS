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
        let second = Double.random(in: 0.4...1.2)
        return Just("2025 LCK Spring")
            .setFailureType(to: WableError.self)
            .delay(for: .seconds(second), scheduler: DispatchQueue.main)
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

        let second = Double.random(in: 0.4...1.2)
        return .just(mockGameSchedules)
            .delay(for: .seconds(second), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError> {
        return .fail(.networkError)
    }
    
    func fetchNews(cursor: Int) -> AnyPublisher<[Announcement], WableError> {
        return .fail(.networkError)
    }
    
    func fetchNotice(cursor: Int) -> AnyPublisher<[Announcement], WableError> {
        return .fail(.networkError)
    }
    
    func fetchNewsNoticeNumber() -> AnyPublisher<(newsNumber: Int, noticeNumber: Int), WableError> {
        return .fail(.networkError)
    }
}
