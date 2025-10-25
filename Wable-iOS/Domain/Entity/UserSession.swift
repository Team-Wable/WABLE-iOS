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
    var quizCompletedAt: Date?
}

// MARK: - 유저 활동

struct UserActivity {
    static let `default` = UserActivity(lastViewedCurationID: 0, lastViewedNoticeCount: 0)

    var lastViewedCurationID: UInt
    var lastViewedNoticeCount: UInt
}

extension UserActivity: Codable {
    enum CodingKeys: CodingKey {
        case lastViewedCurationID, lastViewedNoticeCount
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.lastViewedCurationID = try container.decode(UInt.self, forKey: .lastViewedCurationID)
        self.lastViewedNoticeCount = try container.decodeIfPresent(UInt.self, forKey: .lastViewedNoticeCount) ?? .zero
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.lastViewedCurationID, forKey: .lastViewedCurationID)
        try container.encode(self.lastViewedNoticeCount, forKey: .lastViewedNoticeCount)
    }
}
