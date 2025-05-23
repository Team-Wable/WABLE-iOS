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
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return response.map { comment in
            let url = URL(string: comment.memberProfileURL)
            let fanTeam = LCKTeam(rawValue: comment.memberFanTeam)
            let date = dateFormatter.date(from: comment.time)
            
            let postStatus: PostStatus
            if let isBlind = comment.isBlind, isBlind {
                postStatus = .blind
            } else if comment.isGhost {
                postStatus = .ghost
            } else {
                postStatus = .normal
            }
            
            return UserComment(
                comment: CommentInfo(
                    author: User(
                        id: comment.memberID,
                        nickname: comment.memberNickname,
                        profileURL: url,
                        fanTeam: fanTeam
                    ),
                    id: comment.commentID,
                    text: comment.commentText,
                    createdDate: date,
                    status: postStatus,
                    like: Like(
                        status: comment.isLiked,
                        count: comment.commentLikedNumber
                    ),
                    opacity: Opacity(value: comment.memberGhost)
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
            
            let postStatus: PostStatus
            if comment.isBlind {
                postStatus = .blind
            } else if comment.isGhost {
                postStatus = .ghost
            } else {
                postStatus = .normal
            }
            
            return ContentComment(
                comment: CommentInfo(
                    author: User(
                        id: comment.memberID,
                        nickname: comment.memberNickname,
                        profileURL: url,
                        fanTeam: fanTeam
                    ),
                    id: comment.commentID,
                    text: comment.commentText,
                    createdDate: date,
                    status: postStatus,
                    like: Like(
                        status: comment.isLiked,
                        count: comment.commentLikedNumber
                    ),
                    opacity: Opacity(value: comment.memberGhost)
                ),
                parentID: comment.parentCommentID,
                isDeleted: comment.isDeleted,
                childs: comment.childComments.map(toDomain) ?? []
            )
        }
    }
}
