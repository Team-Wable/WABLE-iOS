//
//  FeedDetailReplyDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/19/24.
//

// MARK: - Datum
struct FeedDetailReplyDTO: Codable {
    let commentID, memberID: Int
    let memberProfileURL, memberNickname: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let commentLikedNumber: Int
    let commentText, time: String
    let isDeleted: Bool
    let commentImageURL, memberFanTeam: String

    enum CodingKeys: String, CodingKey {
        case commentID = "commentId"
        case memberID = "memberId"
        case memberProfileURL = "memberProfileUrl"
        case memberNickname, isGhost, memberGhost, isLiked, commentLikedNumber, commentText, time, isDeleted
        case commentImageURL = "commentImageUrl"
        case memberFanTeam
    }
}
