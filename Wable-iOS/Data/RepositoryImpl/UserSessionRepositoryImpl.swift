//
//  UserSessionRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/2/25.
//


import Combine
import Foundation

class UserSessionRepositoryImpl {
    private enum Keys {
        static let userSessions = "sessionDictionary"
        static let activeUserID = "activeID"
    }
    
    private let userDefaults: LocalKeyValueProvider
    private let tokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    
    init(userDefaults: LocalKeyValueProvider) {
        self.userDefaults = userDefaults
    }
}

// MARK: - UserSessionRepository

extension UserSessionRepositoryImpl: UserSessionRepository {
    func fetchAllUserSessions() -> [String: UserSession] {
        return (try? userDefaults.getValue(for: Keys.userSessions)) ?? [:]
    }
    
    func fetchUserSession(forUserID userID: String) -> UserSession? {
        return fetchAllUserSessions()[userID]
    }
    
    func fetchActiveUserSession() -> UserSession? {
        guard let activeUserID = fetchActiveUserID() else {
            return nil
        }
        return fetchUserSession(forUserID: activeUserID)
    }
    
    func fetchActiveUserID() -> String? {
        return try? userDefaults.getValue(for: Keys.activeUserID)
    }
    
    func updateUserSession(_ session: UserSession, forUserID userID: String) {
        var sessions = fetchAllUserSessions()
        
        sessions[userID] = session
        
        try? userDefaults.setValue(sessions, for: Keys.userSessions)
        
        if fetchActiveUserID() == nil {
            updateActiveUserID(forUserID: userID)
        }
    }
    
    func updateAutoLogin(enabled: Bool, forUserID userID: String) {
        var sessions = fetchAllUserSessions()
        
        if let session = sessions[userID] {
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
            try? userDefaults.setValue(sessions, for: Keys.userSessions)
        }
    }
    
    func updateNotificationBadge(count: Int, forUserID userID: String) {
        var sessions = fetchAllUserSessions()
        
        if let session = sessions[userID] {
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
            try? userDefaults.setValue(sessions, for: Keys.userSessions)
        }
    }
    
    func updateActiveUserID(forUserID userID: String?) {
        if let userID = userID {
            try? userDefaults.setValue(userID, for: Keys.activeUserID)
        }
    }
    
    func removeUserSession(forUserID userID: String) {
        var sessions = fetchAllUserSessions()
        
        sessions.removeValue(forKey: userID)
        try? userDefaults.setValue(sessions, for: Keys.userSessions)
        
        if fetchActiveUserID() == userID {
            updateActiveUserID(forUserID: nil)
        }
    }
}

// MARK: - 자동 로그인 관련 Extension

extension UserSessionRepositoryImpl {
    func checkAutoLogin() -> AnyPublisher<Bool, Error> {
            guard let userSession = fetchActiveUserSession(),
                  userSession.isAutoLoginEnabled == true else {
                return .just(false)
            }
            
            do {
                let _ = try tokenStorage.load(.wableAccessToken), _ = try tokenStorage.load(.wableRefreshToken)
                return .just(true)
            } catch {
                return .fail(error)
            }
        }
        
        func enableAutoLogin(for userID: String) {
            updateAutoLogin(enabled: true, forUserID: userID)
        }
        
        func disableAutoLogin(for userID: String) {
            updateAutoLogin(enabled: false, forUserID: userID)
        }
}
