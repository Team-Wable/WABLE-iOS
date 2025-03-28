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
    
    // MARK: - LifeCycle

    init(userDefaults: LocalKeyValueProvider) {
        self.userDefaults = userDefaults
    }
}

// MARK: - UserSessionRepository

extension UserSessionRepositoryImpl: UserSessionRepository {
    func fetchAllUserSessions() -> [Int: UserSession] {
        return (try? userDefaults.getValue(for: Keys.userSessions)) ?? [:]
    }
    
    func fetchUserSession(forUserID userID: Int) -> UserSession? {
        return fetchAllUserSessions()[userID]
    }
    
    func fetchActiveUserSession() -> UserSession? {
        guard let activeUserID = fetchActiveUserID() else {
            return nil
        }
        return fetchUserSession(forUserID: activeUserID)
    }
    
    func fetchActiveUserID() -> Int? {
        return try? userDefaults.getValue(for: Keys.activeUserID)
    }
    
    /// Updates or adds a user session for the provided user identifier.
    /// 
    /// This method retrieves all stored user sessions, updates the session for the specified
    /// user ID, and attempts to persist the changes to local storage. If no active user session
    /// is set, the provided user ID is designated as active.
    /// 
    /// - Parameters:
    ///   - session: The user session information to be stored.
    ///   - userID: The identifier of the user whose session is being updated.
    func updateUserSession(_ session: UserSession, forUserID userID: Int) {
        var sessions = fetchAllUserSessions()
        
        sessions[userID] = session
        
        try? userDefaults.setValue(sessions, for: Keys.userSessions)
        
        if fetchActiveUserID() == nil {
            updateActiveUserID(userID)
        }
    }
    
    /// Updates the notification badge count for a user's session.
    ///
    /// This method retrieves all stored user sessions and checks if a session exists for the specified user ID.
    /// If a session is found, it creates a new session object with the updated notification badge count while retaining
    /// the other session details, and then saves the updated sessions back to storage.
    /// If no session exists for the provided user ID, no update is performed.
    ///
    /// - Parameters:
    ///   - count: The new badge count to apply to the session.
    ///   - forUserID: The identifier of the user whose session should be updated.
    func updateNotificationBadge(count: Int, forUserID userID: Int) {
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
    
    func updateActiveUserID(_ userID: Int?) {
        if let userID = userID {
            try? userDefaults.setValue(userID, for: Keys.activeUserID)
        }
    }
    
    func removeUserSession(forUserID userID: Int) {
        var sessions = fetchAllUserSessions()
        
        sessions.removeValue(forKey: userID)
        try? userDefaults.setValue(sessions, for: Keys.userSessions)
        
        if fetchActiveUserID() == userID {
            updateActiveUserID(nil)
        }
    }
}

// MARK: - 자동 로그인 관련 Extension

extension UserSessionRepositoryImpl {
    /// Checks whether auto-login is enabled for the active user session by validating token availability.
    ///
    /// This method first retrieves the active user session and confirms that auto-login is enabled. It then attempts to load both the access and refresh tokens from storage. A successful token load indicates that auto-login is active, resulting in a publisher that emits `true`. If there is no active session, auto-login is disabled, or token loading fails, the method returns a publisher that emits `false` or fails with the encountered error.
    ///
    /// - Returns: A publisher that emits a Boolean value indicating the auto-login status or fails if token loading encounters an error.
    func checkAutoLogin() -> AnyPublisher<Bool, Error> {
        guard let userSession = fetchActiveUserSession(),
              userSession.isAutoLoginEnabled == true
        else {
            return .just(false)
        }
        
        do {
            let _ = try tokenStorage.load(.wableAccessToken),
                _ = try tokenStorage.load(.wableRefreshToken)
            return .just(true)
        } catch {
            return .fail(error)
        }
    }
}
