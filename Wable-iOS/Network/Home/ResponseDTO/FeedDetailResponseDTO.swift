//
//  FeedDetailResponseDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/30/24.
//

import Foundation

struct FeedDetailResponseDTO: Decodable {
    let memberId: Int
    let memberProfileUrl: String
    let memberNickname: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let time: String
    let likedNumber: Int
    let commentNumber: Int
    let contentTitle: String
    let contentText: String
    let contentImageUrl: String?
    let memberFanTeam: String
    let isBlind: Bool?
}
