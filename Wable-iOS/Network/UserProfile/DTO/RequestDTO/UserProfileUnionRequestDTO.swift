//
//  UserProfileUnionRequestDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation
import UIKit

// MARK: - UserProfileUnionRequestDTO

struct UserProfileUnionRequestDTO: Encodable {
    var info: UserProfileRequestDTO?
    var file: Data?
}

struct UserProfileRequestDTO: Codable {
    var nickname: String?
    var isAlarmAllowed: Bool?
    var memberIntro: String?
    var isPushAlarmAllowed: Bool?
    var fcmToken: String?
    var memberLckYears: Int?
    var memberFanTeam: String?
    var memberDefaultProfileImage: String?
}
