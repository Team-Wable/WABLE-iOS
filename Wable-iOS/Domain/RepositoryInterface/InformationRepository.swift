//
//  InformationRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

protocol InformationRepository {
    func fetchGameSchedules() -> AnyPublisher<[GameSchedule], WableError>
    func fetchGameCategory() -> AnyPublisher<String, WableError>
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError>
    func fetchNewsNoticeNumber() -> AnyPublisher<(newsNumber: Int, noticeNumber: Int), WableError>
    func fetchNews(cursor: Int) -> AnyPublisher<[Announcement], WableError>
    func fetchNotice(cursor: Int) -> AnyPublisher<[Announcement], WableError>
    func fetchCurations(cursor: Int) -> AnyPublisher<[Curation], WableError>
}
