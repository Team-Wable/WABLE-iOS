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
    func updateUserSession(userID: Int,
                           nickname: String?,
                           profileURL: URL?,
                           isPushAlarmAllowed: Bool?,
                           isAdmin: Bool?,
                           isAutoLoginEnabled: Bool?,
                           notificationBadgeCount: Int?)
    func updateActiveUserID(_ userID: Int?)
    func removeUserSession(forUserID userID: Int)
}
