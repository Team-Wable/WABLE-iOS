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
    func fetchCurations(with lastItemID: Int) -> AnyPublisher<[Curation], WableError>
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

    func fetchCurations(with lastItemID: Int) -> AnyPublisher<[Curation], WableError> {
        return repository.fetchCurations(cursor: lastItemID)
    }
}
