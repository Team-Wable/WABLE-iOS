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
