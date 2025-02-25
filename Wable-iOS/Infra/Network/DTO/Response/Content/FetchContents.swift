//
//  FetchContents.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 게시물 리스트 조회 (배열)

extension DTO.Response {
    struct FetchContents: Decodable {
        let memberID: Int
        let memberProfileURL, memberNickname: String
        let contentID: Int
        let contentTitle: String
        let contentText: String
        let time: String
        let isGhost: Bool
        let memberGhost: Int
        let isLiked: Bool
        let likedNumber, commentNumber: Int
        let isDeleted: Bool
        let contentImageURL: String
        let memberFanTeam: String
        let isBlind: Bool?
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case memberProfileURL = "memberProfileUrl"
            case memberNickname
            case contentID = "contentId"
            case contentTitle, contentText, time, isGhost, memberGhost, isLiked, likedNumber, commentNumber, isDeleted
            case contentImageURL = "contentImageUrl"
            case memberFanTeam, isBlind
        }
    }
}
