//
//  MyPageMemberContentResponseDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation

// MARK: - MyPageMemberContentResponseDTO

struct MyPageMemberContentResponseDTO: Decodable {
    let memberId: Int
    let memberProfileUrl: String
    let memberNickname: String
    let contentId: Int
    let contentTitle: String
    let contentText: String
    let time: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let likedNumber: Int
    let commentNumber: Int
    let contentImageUrl: String?
    let memberFanTeam: String
}
