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
    
    private let userDefaults: UserDefaultsStorage
    private let tokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    
    // MARK: - LifeCycle

    init(userDefaults: UserDefaultsStorage) {
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
    
    func updateUserSession(
        userID: Int,
        nickname: String? = nil,
        profileURL: URL? = nil,
        isPushAlarmAllowed: Bool? = nil,
        isAdmin: Bool? = nil,
        isAutoLoginEnabled: Bool? = nil,
        notificationBadgeCount: Int? = nil
    ) {
        var sessions = fetchAllUserSessions()
        let existingSession = sessions[userID]
        
        let updatedSession = UserSession(
            id: userID,
            nickname: nickname ?? existingSession?.nickname ?? "사용자",
            profileURL: profileURL ?? existingSession?.profileURL,
            isPushAlarmAllowed: isPushAlarmAllowed ?? existingSession?.isPushAlarmAllowed ?? false,
            isAdmin: isAdmin ?? existingSession?.isAdmin ?? false,
            isAutoLoginEnabled: isAutoLoginEnabled ?? existingSession?.isAutoLoginEnabled ?? true,
            notificationBadgeCount: notificationBadgeCount ?? existingSession?.notificationBadgeCount ?? 0
        )
        
        sessions[userID] = updatedSession
        try? userDefaults.setValue(sessions, for: Keys.userSessions)
        
        if fetchActiveUserID() == nil {
            updateActiveUserID(userID)
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
