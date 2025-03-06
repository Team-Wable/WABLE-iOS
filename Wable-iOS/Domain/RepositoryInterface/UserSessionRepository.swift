//
//  UserSessionRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/2/25.
//


import Foundation
import Combine

// MARK: - UserSessionRepository

protocol UserSessionRepository {
    func fetchAllUserSessions() -> [Int: UserSession]
    func fetchUserSession(forUserID userID: Int) -> UserSession?
    func fetchActiveUserSession() -> UserSession?
    func fetchActiveUserID() -> Int?
    func updateUserSession(_ session: UserSession, forUserID userID: Int)
    func updateAutoLogin(enabled: Bool, forUserID userID: Int)
    func updateNotificationBadge(count: Int, forUserID userID: Int)
    func updateActiveUserID(forUserID userID: Int?)
    func removeUserSession(forUserID userID: Int)
    func checkAutoLogin() -> AnyPublisher<Bool, Error>
}
