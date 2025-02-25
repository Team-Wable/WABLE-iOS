//
//  CommentMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum CommentMapper { }

extension CommentMapper {
    static func toDomain(_ response: [DTO.Response.FetchUserComments]) -> [UserComment] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return response.map { comment in
            let url = URL(string: comment.memberProfileURL)
            let fanTeam = LCKTeam(rawValue: comment.memberFanTeam)
            let date = dateFormatter.date(from: comment.time)
            
            return UserComment(
                comment: Comment(
                    author: User(
                        id: comment.memberID,
                        nickname: comment.memberNickname,
                        profileURL: url,
                        fanTeam: fanTeam
                    ),
                    id: comment.commentID,
                    text: comment.commentText,
                    createdDate: date,
                    isLiked: comment.isLiked,
                    isGhost: comment.isGhost,
                    isBlind: comment.isBlind,
                    ghostCount: comment.memberGhost,
                    likeNumber: comment.commentLikedNumber
                ),
                contentID: comment.contentID
            )
        }
    }
    
    static func toDomain(_ response: [DTO.Response.FetchContentComments]) -> [ContentComment] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        
        return response.map { comment in
            let url = URL(string: comment.memberProfileURL)
            let fanTeam = LCKTeam(rawValue: comment.memberFanTeam)
            let date = dateFormatter.date(from: comment.time)
            
            return ContentComment(
                comment: Comment(
                    author: User(
                        id: comment.memberID,
                        nickname: comment.memberNickname,
                        profileURL: url,
                        fanTeam: fanTeam
                    ),
                    id: comment.commentID,
                    text: comment.commentText,
                    createdDate: date,
                    isLiked: comment.isLiked,
                    isGhost: comment.isGhost,
                    isBlind: comment.isBlind,
                    ghostCount: comment.memberGhost,
                    likeNumber: comment.commentLikedNumber
                ),
                parentID: comment.parentCommentID,
                isDeleted: comment.isDeleted,
                childs: comment.childComments.map(toDomain) ?? []
            )
        }
    }
}
