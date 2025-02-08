//
//  SocialLoginResponseDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation

// MARK: - SocilLoginResponseDTO

struct SocialLoginResponseDTO: Codable {
    let nickName: String
    let memberId: Int
    let accessToken, refreshToken: String
    let memberProfileUrl: String
    let isNewUser: Bool
    let isPushAlarmAllowed: Bool?
    let memberFanTeam: String
    let memberLckYears: Int
    let memberLevel: Int
    let isAdmin: Bool
}
