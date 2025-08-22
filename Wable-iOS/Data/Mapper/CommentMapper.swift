//
//  CommentMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum CommentMapper { }

extension CommentMapper {
    static func toDomain(_ response: [DTO.Response.FetchUserComments]) -> [CommentTemp] {
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
            
            return CommentTemp(
                id: comment.commentID,
                author: User(
                    id: comment.memberID,
                    nickname: comment.memberNickname,
                    profileURL: url,
                    fanTeam: fanTeam
                ),
                text: comment.commentText,
                contentID: comment.contentID,
                isDeleted: false,
                createdDate: date,
                parentContentID: nil,
                children: [],
                likeCount: comment.likedCount,
                isLiked: comment.isLiked,
                opacity: Opacity(value: comment.memberGhost),
                status: postStatus
            )
        }
    }
    
    static func toDomain(_ contentID: Int, _ response: [DTO.Response.FetchContentComments]) -> [CommentTemp] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
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
            
            return CommentTemp(
                id: comment.commentID,
                author: User(
                    id: comment.memberID,
                    nickname: comment.memberNickname,
                    profileURL: url,
                    fanTeam: fanTeam
                ),
                text: comment.commentText,
                contentID: contentID,
                isDeleted: comment.isDeleted,
                createdDate: date,
                parentContentID: comment.parentCommentID,
                children: CommentMapper.toDomain(contentID, comment.childComments ?? []),
                likeCount: comment.likedCount,
                isLiked: comment.isLiked,
                opacity: Opacity(value: comment.memberGhost),
                status: postStatus
            )
        }
    }
}
