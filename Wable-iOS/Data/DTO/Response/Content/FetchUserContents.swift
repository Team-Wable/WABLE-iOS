//
//  FetchUserContents.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/17/25.
//


import Foundation

// MARK: - 멤버에 해당하는 게시물 리스트 조회 (배열)

extension DTO.Response {
    struct FetchUserContents: Decodable {
        let memberID: Int
        let memberProfileURL: String
        let memberNickname: String
        let contentID: Int
        let contentTitle: String
        let contentText: String
        let time: String
        let isGhost: Bool
        let memberGhost: Int
        let isLiked: Bool
        let likedNumber: Int
        let commentNumber: Int
        let contentImageURL: String?
        let memberFanTeam: String
        let isBlind: Bool?
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case memberProfileURL = "memberProfileUrl"
            case memberNickname
            case contentID = "contentId"
            case contentTitle, contentText, time, isGhost, memberGhost, isLiked, likedNumber, commentNumber
            case contentImageURL = "contentImageUrl"
            case memberFanTeam = "memberFanTeam"
            case isBlind
        }
    }
}

