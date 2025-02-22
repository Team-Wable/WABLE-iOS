//
//  FetchContent.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/17/25.
//

import Foundation

// MARK: - 게시물 상세 조회

extension DTO.Response {
    struct FetchContent: Decodable {
        let memberID: Int
        let memberProfileURL: String
        let memberNickname: String
        let isGhost: Bool
        let memberGhost: Int
        let isLiked: Bool
        let time: String
        let likedNumber: Int
        let commentNumber: Int
        let contentText: String
        let contentImageURL: String?
        let memberFanTeam: String
        let isBlind: Bool?
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case memberProfileURL = "memberProfileUrl"
            case memberNickname, isGhost, memberGhost, isLiked, time, likedNumber, commentNumber, contentText
            case contentImageURL = "contentImageUrl"
            case memberFanTeam, isBlind
        }
    }
}
