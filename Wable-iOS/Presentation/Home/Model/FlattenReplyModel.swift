//
//  FlattenReplyModel.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 11/19/24.
//

import Foundation

struct FlattenReplyModel {
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
}

extension FlattenReplyModel: Hashable {
    static func == (lhs: FlattenReplyModel, rhs: FlattenReplyModel) -> Bool {
        lhs.commentID == rhs.commentID
    }
}
