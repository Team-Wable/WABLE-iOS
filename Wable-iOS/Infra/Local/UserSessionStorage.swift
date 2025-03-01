//
//  UserSessionStorage.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/2/25.
//


import Foundation

// MARK: - UserSessionStorage

protocol UserSessionStorage {
    func fetchAllUserSessions() -> [String: UserSession]
    func fetchUserSession(forUserID userID: String) -> UserSession?
    func fetchActiveUserSession() -> UserSession?
    func fetchActiveUserID() -> String?
    func updateUserSession(_ session: UserSession, forUserID userID: String)
    func updateAutoLogin(enabled: Bool, forUserID userID: String)
    func updateNotificationBadge(count: Int, forUserID userID: String)
    func updateActiveUserID(forUserID userID: String?)
    func removeUserSession(forUserID userID: String)
}
