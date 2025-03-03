//
//  UserSessionWrapper.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/2/25.
//


import Foundation

class UserSessionWrapper {
    private enum Keys {
        static let userSessions = "sessionDictionary"
        static let activeUserID = "activeID"
    }
    
    private let defaults = UserDefaults.standard
}

// MARK: - Private Helper

extension UserSessionWrapper {
    private func fetchSessions() -> [String: UserSession] {
        guard let data = defaults.data(forKey: Keys.userSessions),
              let sessions = try? JSONDecoder().decode([String: UserSession].self, from: data)
        else {
            return [:]
        }
        return sessions
    }
    
    private func updateSessions(_ sessions: [String: UserSession]) {
        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: Keys.userSessions)
        }
    }
}

// MARK: - UserSessionStorage

extension UserSessionWrapper: UserSessionStorage {
    func fetchAllUserSessions() -> [String: UserSession] {
        return fetchSessions()
    }
    
    func fetchUserSession(forUserID userID: String) -> UserSession? {
        return fetchSessions()[userID]
    }
    
    func fetchActiveUserSession() -> UserSession? {
        guard let activeUserID = fetchActiveUserID() else {
            return nil
        }
        return fetchUserSession(forUserID: activeUserID)
    }
    
    func fetchActiveUserID() -> String? {
        return defaults.string(forKey: Keys.activeUserID)
    }
    
    func updateUserSession(_ session: UserSession, forUserID userID: String) {
        var sessions = fetchSessions()
        sessions[userID] = session
        updateSessions(sessions)
        
        if fetchActiveUserID() == nil {
            updateActiveUserID(forUserID: userID)
        }
    }
    
    func updateAutoLogin(enabled: Bool, forUserID userID: String) {
        var sessions = fetchSessions()
        if var session = sessions[userID] {
            let updatedSession = UserSession(
                id: session.id,
                nickname: session.nickname,
                profileURL: session.profileURL,
                isPushAlarmAllowed: session.isPushAlarmAllowed,
                isAdmin: session.isAdmin,
                isAutoLoginEnabled: enabled,
                notificationBadgeCount: session.notificationBadgeCount
            )
            
            sessions[userID] = updatedSession
            updateSessions(sessions)
        }
    }
    
    func updateNotificationBadge(count: Int, forUserID userID: String) {
        var sessions = fetchSessions()
        if var session = sessions[userID] {
            let updatedSession = UserSession(
                id: session.id,
                nickname: session.nickname,
                profileURL: session.profileURL,
                isPushAlarmAllowed: session.isPushAlarmAllowed,
                isAdmin: session.isAdmin,
                isAutoLoginEnabled: session.isAutoLoginEnabled,
                notificationBadgeCount: count
            )
            sessions[userID] = updatedSession
            updateSessions(sessions)
        }
    }
    
    func updateActiveUserID(forUserID userID: String?) {
        if let userID = userID {
            defaults.set(userID, forKey: Keys.activeUserID)
        } else {
            defaults.removeObject(forKey: Keys.activeUserID)
        }
    }
    
    func removeUserSession(forUserID userID: String) {
        var sessions = fetchSessions()
        sessions.removeValue(forKey: userID)
        updateSessions(sessions)
        
        if fetchActiveUserID() == userID {
            updateActiveUserID(forUserID: nil)
        }
    }
}

