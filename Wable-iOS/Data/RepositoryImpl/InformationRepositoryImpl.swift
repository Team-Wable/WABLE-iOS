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
    
    func fetchCurations(cursor: Int) -> AnyPublisher<[Curation], WableError> {
        return provider.request(
            .fetchCurations(cursor: cursor),
            for: [DTO.Response.FetchCurations].self
        )
        .map(InformationMapper.toDomain(_:))
        .mapWableError()
    }
}

// MARK: - MockInformationRepository

struct MockInformationRepository: InformationRepository {
    func fetchGameSchedules() -> AnyPublisher<[GameSchedule], WableError> {
        return createMockGameSchedules()
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchGameCategory() -> AnyPublisher<String, WableError> {
        return .just("2025 LCK SPRING")
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError> {
        return createMockTeamRanks()
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchNewsNoticeNumber() -> AnyPublisher<(newsNumber: Int, noticeNumber: Int), WableError> {
        return .just((newsNumber: 12, noticeNumber: 3))
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchNews(cursor: Int) -> AnyPublisher<[Announcement], WableError> {
        return createMockAnnouncements(lastItemID: cursor, prefix: "뉴스")
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchNotice(cursor: Int) -> AnyPublisher<[Announcement], WableError> {
        return createMockAnnouncements(lastItemID: cursor, prefix: "공지사항")
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchCurations(cursor: Int) -> AnyPublisher<[Curation], WableError> {
        return createMockCurations(lastItemID: cursor)
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private var randomDelaySecond: Double { .random(in: 0.3...1.0) }

    private func createMockGameSchedules() -> AnyPublisher<[GameSchedule], WableError> {
        let teamNames: [String] = [
            "T1", "GEN", "HLE", "DK", "KT", "NS", "DRX", "BRO", "BFX", "DNF",
            "VKS", "AL", "BLG", "CFO", "FLY", "FNC", "G2", "IG", "MKOI", "PSG", 
            "TES", "TSW", "100T", "TBD"
        ]
        var mockGameSchedules: [GameSchedule] = []
        
        for dayOffset in 0...6 {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
            var games: [Game] = []
            
            let rotatedTeams: [String] = (0..<teamNames.count).map { teamNames[($0 + dayOffset) % teamNames.count] }
            for pairIndex in stride(from: 0, to: rotatedTeams.count, by: 2) {
                let homeTeam = rotatedTeams[pairIndex]
                let awayTeam = rotatedTeams[pairIndex + 1]

                let gameNumber = pairIndex / 2
                let game = Game(
                    date: date,
                    homeTeam: homeTeam,
                    homeScore: gameNumber * 2 + 1,
                    awayTeam: awayTeam,
                    awayScore: gameNumber * 2 + 2,
                    status: .scheduled
                )
                games.append(game)
            }
            
            mockGameSchedules.append(GameSchedule(date: date, games: games))
        }
        
        return .just(mockGameSchedules)
    }
    
    private func createMockTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError> {
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
    }
    
    private func createMockAnnouncements(lastItemID: Int, prefix: String) -> AnyPublisher<[Announcement], WableError> {
        let range: ClosedRange<Int>
        
        switch lastItemID {
        case -1:
            range = 1...15
        case 15:
            range = 16...30
        case 30:
            range = 31...33
        default:
            return .just([])
        }
        
        let announcements = range.map { id in
            Announcement(
                id: id,
                title: "\(prefix) \(id)",
                imageURL: URL(string: Constant.imageURLText),
                text: "이것은 \(prefix) \(id)입니다.",
                createdDate: Calendar.current.date(byAdding: .day, value: -id, to: Date())
            )
        }
        
        return .just(announcements)
    }
    
    private func createMockCurations(lastItemID: Int) -> AnyPublisher<[Curation], WableError> {
        let range: ClosedRange<Int>

        switch lastItemID {
        case -1:
            range = 1...15
        case 15:
            range = 16...30
        case 30:
            range = 31...45
        default:
            return .just([])
        }

        let now = Date()
        let curations: [Curation] = range.map { id in
            let minutesAgo = id * 5
            let time = Calendar.current.date(byAdding: .minute, value: -minutesAgo, to: now) ?? now
            let url = URL(string: "https://example.com/video/\(id)")!
            let thumb = URL(string: "https://picsum.photos/seed/curation\(id)/343/220")!
            return Curation(
                id: id,
                title: "큐레이션 영상 제목 \(id)",
                time: time,
                url: url,
                thumbnailURL: thumb
            )
        }

        return .just(curations)
    }
    
    private enum Constant {
        static let imageURLText: String = "https://picsum.photos/300"
    }
}
