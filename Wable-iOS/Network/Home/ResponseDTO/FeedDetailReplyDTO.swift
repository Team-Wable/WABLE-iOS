//
//  FeedDetailReplyDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/19/24.
//

// MARK: - Datum
struct FeedDetailReplyDTO: Codable {
    let commentId: Int
    let memberId: Int
    let memberProfileUrl: String
    let memberNickname: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let commentLikedNumber: Int
    let commentText: String
    let time: String
    let isDeleted: Bool
    let commentImageUrl: String?
    let memberFanTeam: String
}

// MARK: - 1.1.0v DTO

struct FeedReplyListDTO: Codable {
    let commentID, memberID: Int
    let memberProfileURL, memberNickname: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let commentLikedNumber: Int
    let commentText, time: String
    let isDeleted: Bool
    let memberFanTeam: String
    let parentCommentID: Int
    let isBlind: Bool?

    enum CodingKeys: String, CodingKey {
        case commentID = "commentId"
        case memberID = "memberId"
        case memberProfileURL = "memberProfileUrl"
        case memberNickname, isGhost, memberGhost, isLiked, commentLikedNumber, commentText, time, isDeleted, memberFanTeam
        case parentCommentID = "parentCommentId"
        case isBlind
    }
}
