//
//  MypageProfileResponseDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation

// MARK: - MypageProfileResponseDTO

struct MypageProfileResponseDTO: Decodable {
    let memberId: Int
    let nickname: String
    let memberProfileUrl: String
    let memberIntro: String
    let memberGhost: Int
    let memberFanTeam: String
    let memberLckYears: Int
    let memberLevel: Int
}
