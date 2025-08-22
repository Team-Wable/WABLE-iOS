//
//  ContentMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum ContentMapper { }

extension ContentMapper {
    static func toDomain(_ response: DTO.Response.FetchContent, _ id: Int) -> Content {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        let memberProfileURL = URL(string: response.memberProfileURL)
        let contentImageURL = URL(string: response.contentImageURL ?? "")
        let fanTeam = LCKTeam(rawValue: response.memberFanTeam)
        let date = dateFormatter.date(from: response.time)
        
        let postStatus: PostStatus
        if let isBlind = response.isBlind, isBlind {
            postStatus = .blind
        } else if response.isGhost {
            postStatus = .ghost
        } else {
            postStatus = .normal
        }
        
        return Content(
            id: id,
            author: User(
                id: response.memberID,
                nickname: response.memberNickname,
                profileURL: memberProfileURL,
                fanTeam: fanTeam
            ),
            text: response.contentText,
            title: response.contentTitle,
            imageURL: contentImageURL,
            isDeleted: nil,
            createdDate: date,
            isLiked: response.isLiked,
            likeCount: response.likedNumber,
            opacity: Opacity(value: response.memberGhost),
            commentCount: response.commentNumber,
            status: postStatus
        )
    }
    
    static func toDomain(_ response: [DTO.Response.FetchContents]) -> [Content] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return response.map { content in
            let memberProfileURL = URL(string: content.memberProfileURL)
            let contentImageURL = URL(string: content.contentImageURL)
            let fanTeam = LCKTeam(rawValue: content.memberFanTeam)
            let date = dateFormatter.date(from: content.time)
            
            let postStatus: PostStatus
            if let isBlind = content.isBlind, isBlind {
                postStatus = .blind
            } else if content.isGhost {
                postStatus = .ghost
            } else {
                postStatus = .normal
            }
            
            return Content(
                id: content.contentID,
                author: User(
                    id: content.memberID,
                    nickname: content.memberNickname,
                    profileURL: memberProfileURL,
                    fanTeam: fanTeam
                ),
                text: content.contentText,
                title: content.contentTitle,
                imageURL: contentImageURL,
                isDeleted: content.isDeleted,
                createdDate: date,
                isLiked: content.isLiked,
                likeCount: content.likedNumber,
                opacity: Opacity(value: content.memberGhost),
                commentCount: content.commentNumber,
                status: postStatus
            )
        }
    }
    
    static func toDomain(_ response: [DTO.Response.FetchUserContents]) -> [Content] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return response.map { content in
            let memberProfileURL = URL(string: content.memberProfileURL)
            let contentImageURL = URL(string: content.contentImageURL ?? "")
            let fanTeam = LCKTeam(rawValue: content.memberFanTeam)
            let date = dateFormatter.date(from: content.time)
            
            let postStatus: PostStatus
            if let isBlind = content.isBlind, isBlind {
                postStatus = .blind
            } else if content.isGhost {
                postStatus = .ghost
            } else {
                postStatus = .normal
            }
            
            return Content(
                id: content.contentID,
                author: User(
                    id: content.memberID,
                    nickname: content.memberNickname,
                    profileURL: memberProfileURL,
                    fanTeam: fanTeam
                ),
                text: content.contentText,
                title: content.contentTitle,
                imageURL: contentImageURL,
                isDeleted: nil,
                createdDate: date,
                isLiked: content.isLiked,
                likeCount: content.likedNumber,
                opacity: Opacity(value: content.memberGhost),
                commentCount: content.commentNumber,
                status: postStatus
            )
        }
    }
}
