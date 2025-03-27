//
//  OAuthEventManager.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/23/25.
//


import Combine

final class OAuthEventManager {
    static let shared = OAuthEventManager()
    
    let tokenExpiredSubject = PassthroughSubject<Void, Never>()
}
