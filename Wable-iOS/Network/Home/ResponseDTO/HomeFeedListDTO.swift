//
//  HomeFeedListDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import Foundation

struct HomeFeedDTO: Codable {
    let memberID: Int
    let memberProfileURL, memberNickname: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let time: String
    let likedNumber: Int
    let memberFanTeam: String
    let contentID: Int?
    let contentTitle: String?
    let contentText: String?
    let commentNumber: Int?
    let isDeleted: Bool?
    let commnetNumber: Int?
    let contentImageURL: String?
    let isBlind: Bool?

    enum CodingKeys: String, CodingKey {
        case memberID = "memberId"
        case memberProfileURL = "memberProfileUrl"
        case memberNickname, isGhost, memberGhost, isLiked, time, likedNumber, memberFanTeam
        case contentID = "contentId"
        case contentTitle, contentText, commentNumber, isDeleted
        case commnetNumber
        case contentImageURL = "contentImageUrl"
        case isBlind
    }
}

extension HomeFeedDTO: Hashable {
    static func == (lhs: HomeFeedDTO, rhs: HomeFeedDTO) -> Bool {
        lhs.contentID == rhs.contentID
    }
}
