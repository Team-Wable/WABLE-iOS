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
        return lhs.commentID == rhs.commentID &&
               lhs.memberID == rhs.memberID &&
               lhs.memberProfileURL == rhs.memberProfileURL &&
               lhs.memberNickname == rhs.memberNickname &&
               lhs.isGhost == rhs.isGhost &&
               lhs.memberGhost == rhs.memberGhost &&
               lhs.isLiked == rhs.isLiked &&
               lhs.commentLikedNumber == rhs.commentLikedNumber &&
               lhs.commentText == rhs.commentText &&
               lhs.time == rhs.time &&
               lhs.isDeleted == rhs.isDeleted &&
               lhs.memberFanTeam == rhs.memberFanTeam &&
               lhs.parentCommentID == rhs.parentCommentID &&
               lhs.isBlind == rhs.isBlind
    }

}

extension FlattenReplyModel {
    func editWith(
        isGhost: Bool? = nil,
        memberGhost: Int? = nil,
        isLiked: Bool? = nil,
        commentLikedNumber: Int? = nil,
        isBlind: Bool? = nil
    ) -> FlattenReplyModel {
        return FlattenReplyModel(
            commentID: commentID,
            memberID: memberID,
            memberProfileURL: memberProfileURL,
            memberNickname: memberNickname,
            isGhost: isGhost ?? self.isGhost,
            memberGhost: memberGhost ?? self.memberGhost,
            isLiked: isLiked ?? self.isLiked,
            commentLikedNumber: commentLikedNumber ?? self.commentLikedNumber,
            commentText: commentText,
            time: time,
            isDeleted: isDeleted,
            memberFanTeam: memberFanTeam,
            parentCommentID: parentCommentID,
            isBlind: isBlind ?? self.isBlind
        )
    }
    
    func defaultValue() -> FlattenReplyModel {
        return FlattenReplyModel(
            commentID: -1,
            memberID: -1,
            memberProfileURL: "",
            memberNickname: "",
            isGhost: false,
            memberGhost: -1,
            isLiked: false,
            commentLikedNumber: -1,
            commentText: "",
            time: "",
            isDeleted: false,
            memberFanTeam: "",
            parentCommentID: -1,
            isBlind: false)
    }
}
