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
    func updateUserSession(_ session: UserSession)
    func updateNotificationBadge(count: Int, forUserID userID: Int)
    func updateActiveUserID(_ userID: Int?)
    func removeUserSession(forUserID userID: Int)
}
