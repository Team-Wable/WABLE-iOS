//
//  HomeFeedListDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import Foundation

struct HomeFeedDTO: Codable {
    let memberID: Int
    let memberProfileURL: String
    let memberNickname: String
    let contentID: Int
    let contentText, time: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let likedNumber, commentNumber: Int
    let isDeleted: Bool
    let contentImageURL: String?
    let memberFanTeam: String

    enum CodingKeys: String, CodingKey {
        case memberID = "memberId"
        case memberProfileURL = "memberProfileUrl"
        case memberNickname
        case contentID = "contentId"
        case contentText, time, isGhost, memberGhost, isLiked, likedNumber, commentNumber, isDeleted
        case contentImageURL = "contentImageUrl"
        case memberFanTeam
    }
}
