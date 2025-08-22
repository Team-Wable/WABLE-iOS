//
//  FetchContentComments.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 게시물에 해당하는 답글 리스트 조회

extension DTO.Response {
    struct FetchContentComments: Decodable {
        let commentID, memberID: Int
        let memberProfileURL: String
        let memberNickname: String
        let isGhost: Bool
        let memberGhost: Int
        let isLiked: Bool
        let likedCount: Int
        let commentText, time: String
        let isDeleted: Bool
        let commentImageURL: String?
        let memberFanTeam: String
        let parentCommentID: Int
        let isBlind: Bool
        let childComments: [FetchContentComments]?
        
        enum CodingKeys: String, CodingKey {
            case commentID = "commentId"
            case memberID = "memberId"
            case memberProfileURL = "memberProfileUrl"
            case memberNickname, isGhost, memberGhost, isLiked
            case likedCount = "commentLikedNumber"
            case commentText, time, isDeleted
            case commentImageURL = "commentImageUrl"
            case memberFanTeam
            case parentCommentID = "parentCommentId"
            case isBlind, childComments
        }
    }
}
