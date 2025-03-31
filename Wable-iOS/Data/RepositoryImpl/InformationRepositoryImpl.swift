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
