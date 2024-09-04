//
//  HomeFeedContentDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 9/4/24.
//

import Foundation

struct HomeFeedContentDTO: Codable {
    let memberID: Int
    let memberProfileURL, memberNickname: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let time: String
    let likedNumber, commnetNumber: Int
    let message, memberFanTeam: String
    let contentImageURL: String?

    enum CodingKeys: String, CodingKey {
        case memberID = "memberId"
        case memberProfileURL = "memberProfileUrl"
        case memberNickname, isGhost, memberGhost, isLiked, time, likedNumber, commnetNumber, message
        case contentImageURL = "contentImageUrl"
        case memberFanTeam
    }
}
