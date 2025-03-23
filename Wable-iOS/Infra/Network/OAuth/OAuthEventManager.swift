//
//  OAuthEventManager.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/23/25.
//


import Combine

final class AuthEventManager {
    static let shared = AuthEventManager()
    
    let tokenExpiredSubject = PassthroughSubject<Void, Never>()
}
