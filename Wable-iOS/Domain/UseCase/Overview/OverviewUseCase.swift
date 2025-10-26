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
    func fetchNotices(with lastItemID: Int) -> AnyPublisher<[Announcement], WableError>
    func fetchCurationList(with lastItemID: Int) -> AnyPublisher<[Curation], WableError>
    func checkUnviewedCuration() -> AnyPublisher<Bool, WableError>
    func updateLastViewedCurationID(to curationID: Int) -> AnyPublisher<Void, WableError>
    func checkUnviewedNotice() -> AnyPublisher<Bool, WableError>
    func updateLastViewedNoticeCount(to noticeCount: Int) -> AnyPublisher<Void, WableError>
}

// MARK: - OverviewUseCaseImpl

final class OverviewUseCaseImpl: OverviewUseCase {
    @Injected private var informationRepository: InformationRepository
    @Injected private var userSessionRepository: UserSessionRepository
    @Injected private var userActivityRepository: UserActivityRepository
    
    func fetchGameCategory() -> AnyPublisher<String, WableError> {
        return informationRepository.fetchGameCategory()
    }
    
    func fetchGameSchedules() -> AnyPublisher<[GameSchedule], WableError> {
        return informationRepository.fetchGameSchedules()
    }
    
    func fetchTeamRanks() -> AnyPublisher<[LCKTeamRank], WableError> {
        return informationRepository.fetchTeamRanks()
    }
    
    func fetchNotices(with lastItemID: Int) -> AnyPublisher<[Announcement], WableError> {
        return informationRepository.fetchNotice(cursor: lastItemID)
    }

    func fetchCurationList(with lastItemID: Int) -> AnyPublisher<[Curation], WableError> {
        return informationRepository.fetchCurationList(cursor: lastItemID)
    }

    func checkUnviewedCuration() -> AnyPublisher<Bool, WableError> {
        guard let userID = fetchActiveUserID() else {
            return .fail(.invalidMember)
        }

        let lastViewedCurationID = userActivityPublisher(for: userID)
            .map { Int($0.lastViewedCurationID) }
            .eraseToAnyPublisher()

        return Publishers.Zip(informationRepository.fetchLatestCurationID(), lastViewedCurationID)
            .map { $0 > $1 }
            .eraseToAnyPublisher()
    }

    func updateLastViewedCurationID(to curationID: Int) -> AnyPublisher<Void, WableError> {
        guard let userID = fetchActiveUserID() else {
            return .fail(.invalidMember)
        }
        guard let validCurationID = UInt(exactly: curationID) else {
            return .fail(.validationException)
        }

        return userActivityPublisher(for: userID)
            .filter { $0.lastViewedCurationID < validCurationID }
            .flatMap { [userActivityRepository] activity -> AnyPublisher<Void, WableError> in
                var updatedActivity = activity
                updatedActivity.lastViewedCurationID = validCurationID
                return userActivityRepository.updateUserActivity(for: userID, updatedActivity)
            }
            .eraseToAnyPublisher()
    }

    func checkUnviewedNotice() -> AnyPublisher<Bool, WableError> {
        guard let userID = fetchActiveUserID() else {
            return .fail(.invalidMember)
        }

        let lastViewedNoticeCount = userActivityPublisher(for: userID)
            .map { Int($0.lastViewedNoticeCount) }
            .eraseToAnyPublisher()

        let latestNoticeCount = informationRepository.fetchNewsNoticeNumber()
            .map(\.noticeNumber)
            .eraseToAnyPublisher()
        
        return Publishers.Zip(latestNoticeCount, lastViewedNoticeCount)
            .map { $0 > $1 }
            .eraseToAnyPublisher()
    }

    func updateLastViewedNoticeCount(to noticeCount: Int) -> AnyPublisher<Void, WableError> {
        guard let userID = fetchActiveUserID() else {
            return .fail(.invalidMember)
        }
        guard let validNoticeCount = UInt(exactly: noticeCount) else {
            return .fail(.validationException)
        }

        return userActivityPublisher(for: userID)
            .filter { $0.lastViewedNoticeCount < validNoticeCount }
            .flatMap { [userActivityRepository] activity -> AnyPublisher<Void, WableError> in
                var updatedActivity = activity
                updatedActivity.lastViewedNoticeCount = validNoticeCount
                return userActivityRepository.updateUserActivity(for: userID, updatedActivity)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Helper Method

private extension OverviewUseCaseImpl {
    func fetchActiveUserID() -> UInt? {
        guard let activeUserID = userSessionRepository.fetchActiveUserID(),
              let userID = UInt(exactly: activeUserID) 
        else {
            return nil
        }
        return userID
    }

    func userActivityPublisher(for userID: UInt) -> AnyPublisher<UserActivity, WableError> {
        userActivityRepository.fetchUserActivity(for: userID)
            .catch { error -> AnyPublisher<UserActivity, WableError> in
                WableLogger.log("Failed to fetch user activity: \(error)", for: .error)
                return .just(.default)
            }
            .eraseToAnyPublisher()
    }
}
