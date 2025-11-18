//
//  OAuthEventManager.swift
//  Wable-iOS
//
//  Created by YOUJIM on 11/16/25.
//

import Combine
import Foundation

final class OAuthEventManager {
    static let shared = OAuthEventManager()

    let tokenExpiredSubject = PassthroughSubject<Void, Never>()
}
