//
//  UserSession.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/2/25.
//


import Foundation

struct UserSession: Codable, Identifiable {
    let id: Int
    let nickname: String
    let profileURL: URL?
    let isPushAlarmAllowed: Bool
    let isAdmin: Bool
    let isAutoLoginEnabled: Bool?
    let notificationBadgeCount: Int?
}
