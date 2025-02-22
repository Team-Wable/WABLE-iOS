//
//  ContentMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum ContentMapper { }

extension ContentMapper {
    static func contentInfoMapper(_ response: DTO.Response.FetchContent, _ title: String) -> ContentInfo {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
        
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
            likeNumber: response.likedNumber,
            commentNumber: response.commentNumber
        )
    }
    
    static func contentListMapper(_ response: [DTO.Response.FetchContents]) -> [Content] {
        response.map { content in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
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
                        likeNumber: content.likedNumber,
                        commentNumber: content.commentNumber
                    )
                ),
                isDeleted: content.isDeleted
            )
        }
    }
    
    static func userContentListMapper(_ response: [DTO.Response.FetchUserContents]) -> [UserContent] {
        response.map { content in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SS"
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
                    likeNumber: content.likedNumber,
                    commentNumber: content.commentNumber
                )
            )
        }
    }
}
