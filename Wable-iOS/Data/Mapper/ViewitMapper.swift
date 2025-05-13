//
//  ViewitMapper.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//

import Foundation

enum ViewitMapper { }

extension ViewitMapper {
    static func toDomain(_ response: [DTO.Response.FetchViewits]) -> [Viewit] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ""
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        
        return response.map { content in
            let userProfileURL = URL(string: content.memberProfileURL)
            let thumbnailURL = URL(string: content.viewitImage ?? "")
            let videoURL = URL(string: content.viewitLink ?? "")
            let time = dateFormatter.date(from: content.time)
            
            let postStatus: PostStatus
            if content.isBlind {
                postStatus = .blind
            } else {
                postStatus = .normal
            }
            
            return Viewit(
                userID: content.memberID,
                userNickname: content.memberNickname,
                userProfileURL: userProfileURL,
                id: content.viewitID,
                thumbnailURL: thumbnailURL,
                siteURL: videoURL,
                siteName: content.viewitName,
                title: content.viewitTitle,
                text: content.viewitText,
                time: time,
                status: postStatus,
                like: Like(
                    status: content.isLiked,
                    count: content.likedNumber
                )
            )
        }
    }
}

