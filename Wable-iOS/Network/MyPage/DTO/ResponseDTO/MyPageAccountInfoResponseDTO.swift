//
//  MyPageAccountInfoResponseDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//
import Foundation

// MARK: - MyPageAccountInfoResponseDTO

struct MyPageAccountInfoResponseDTO: Decodable {
    let memberId: Int
    let joinDate: String
    let showMemberId: String?
    let socialPlatform: String
    let versionInformation: String
}
