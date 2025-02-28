//
//  ContentMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum ContentMapper { }

extension ContentMapper {
    static func toDomain(_ response: DTO.Response.FetchContent, _ title: String) -> ContentInfo {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        let memberProfileURL = URL(string: response.memberProfileURL)
        let contentImageURL = URL(string: response.contentImageURL ?? "")
        let fanTeam = LCKTeam(rawValue: response.memberFanTeam)
        let date = dateFormatter.date(from: response.time)
        
        return ContentInfo(
            author: User(
                id: response.memberID,
                nickname: response.memberNickname,
                profileURL: memberProfileURL,
                fanTeam: fanTeam
            ),
            createdDate: date,
            title: title,
            imageURL: contentImageURL,
            text: response.contentText,
            ghostCount: response.memberGhost,
            isLiked: response.isLiked,
            isGhost: response.isGhost,
            isBlind: response.isBlind,
            likedCount: response.likedNumber,
            commentCount: response.commentNumber
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
            
            return Content(
                content: UserContent(
                    id: content.contentID,
                    contentInfo: ContentInfo(
                        author: User(
                            id: content.memberID,
                            nickname: content.memberNickname,
                            profileURL: memberProfileURL,
                            fanTeam: fanTeam
                        ),
                        createdDate: date,
                        title: content.contentTitle,
                        imageURL: contentImageURL,
                        text: content.contentText,
                        ghostCount: content.memberGhost,
                        isLiked: content.isLiked,
                        isGhost: content.isGhost,
                        isBlind: content.isBlind,
                        likedCount: content.likedNumber,
                        commentCount: content.commentNumber
                    )
                ),
                isDeleted: content.isDeleted
            )
        }
    }
    
    static func toDomain(_ response: [DTO.Response.FetchUserContents]) -> [UserContent] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return response.map { content in
            let memberProfileURL = URL(string: content.memberProfileURL)
            let contentImageURL = URL(string: content.contentImageURL ?? "")
            let fanTeam = LCKTeam(rawValue: content.memberFanTeam)
            let date = dateFormatter.date(from: content.time)
            
            return UserContent(
                id: content.contentID,
                contentInfo: ContentInfo(
                    author: User(
                        id: content.memberID,
                        nickname: content.memberNickname,
                        profileURL: memberProfileURL,
                        fanTeam: fanTeam
                    ),
                    createdDate: date,
                    title: content.contentTitle,
                    imageURL: contentImageURL,
                    text: content.contentText,
                    ghostCount: content.memberGhost,
                    isLiked: content.isLiked,
                    isGhost: content.isGhost,
                    isBlind: content.isBlind,
                    likedCount: content.likedNumber,
                    commentCount: content.commentNumber
                )
            )
        }
    }
}
