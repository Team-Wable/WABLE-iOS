//
//  OverviewUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//

import Combine
import Foundation

// MARK: - OverviewUseCase

protocol OverviewUseCase {
    func fetchGameCategory() -> AnyPublisher<String, WableError>
    func fetchGameSchedules() -> AnyPublisher<[GameSchedule], WableError>
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError>
    func fetchNews(with lastItemID: Int) -> AnyPublisher<[Announcement], WableError>
    func fetchNotices(with lastItemID: Int) -> AnyPublisher<[Announcement], WableError>
    func checkNewAnnouncements() -> AnyPublisher<(Bool, Bool), WableError>
}

// MARK: - OverviewUseCaseImpl

final class OverviewUseCaseImpl: OverviewUseCase {
    @Injected private var repository: InformationRepository
        
    func fetchGameCategory() -> AnyPublisher<String, WableError> {
        return repository.fetchGameCategory()
    }
    
    func fetchGameSchedules() -> AnyPublisher<[GameSchedule], WableError> {
        return repository.fetchGameSchedules()
    }
    
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError> {
        return repository.fetchTeamRanks()
    }
    
    func fetchNews(with lastItemID: Int) -> AnyPublisher<[Announcement], WableError> {
        return repository.fetchNews(cursor: lastItemID)
    }
    
    func fetchNotices(with lastItemID: Int) -> AnyPublisher<[Announcement], WableError> {
        return repository.fetchNotice(cursor: lastItemID)
    }
    
    func checkNewAnnouncements() -> AnyPublisher<(Bool, Bool), WableError> {
        
        // TODO: 서버에서 받아오는 값과 로컬에 저장한 값을 비교 후, 결과 리턴
        
        // 서버에서 받아온 값: repository.fetchNewsNoticeNumber()
        // 로컬에 저장하기 위한 방법 구현 필요
        
        return .just((false, false))
    }
}

// MARK: - MockOverviewUseCaseImpl

struct MockOverviewUseCaseImpl: OverviewUseCase {
    
    private var randomDelaySecond: Double { .random(in: 0.3...1.0) }
    
    private let lckTeams: [LCKTeam] = [.t1, .gen, .hle, .dk, .kt, .ns, .drx, .bro, .bfx, .dnf]
        
    func fetchGameCategory() -> AnyPublisher<String, WableError> {
        return .just("2025 LCK SPRING")
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchGameSchedules() -> AnyPublisher<[GameSchedule], WableError> {
        return createMockGameSchedules()
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError> {
        return createMockTeamRanks()
            .delay(for: .seconds(randomDelaySecond), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchNews(with lastItemID: Int) -> AnyPublisher<[Announcement], WableError> {
        return createMockAnnouncements(lastItemID: lastItemID, prefix: "뉴스")
            .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func fetchNotices(with lastItemID: Int) -> AnyPublisher<[Announcement], WableError> {
        return createMockAnnouncements(lastItemID: lastItemID, prefix: "공지사항")
            .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func checkNewAnnouncements() -> AnyPublisher<(Bool, Bool), WableError> {
        return .just((true, true))
            .delay(for: .seconds(randomDelaySecond), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private func createMockGameSchedules() -> AnyPublisher<[GameSchedule], WableError> {
        var mockGameSchedules: [GameSchedule] = []
        
        for dayOffset in 0...6 {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
            var games: [Game] = []
            
            for index in 0...4 {
                let homeTeamIndex = index * 2 % lckTeams.count
                let awayTeamIndex = (index * 2 + 1) % lckTeams.count
                
                let game = Game(
                    date: date,
                    homeTeam: lckTeams[homeTeamIndex],
                    homeScore: index * 2 + 1,
                    awayTeam: lckTeams[awayTeamIndex],
                    awayScore: index * 2 + 2,
                    status: .scheduled
                )
                games.append(game)
            }
            
            mockGameSchedules.append(GameSchedule(date: date, games: games))
        }
        
        return .just([])
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
    
    private enum Constant {
        static let imageURLText: String = "https://picsum.photos/300"
    }
}
