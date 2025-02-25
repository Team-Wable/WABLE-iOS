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
            let thumbnailURL = URL(string: content.viewitImage)
            let videoURL = URL(string: content.viewitLink)
            let time = dateFormatter.date(from: content.time)
            
            return Viewit(
                userID: content.memberID,
                viewitID: content.viewitID,
                userNickname: content.memberNickname,
                userProfileURL: userProfileURL,
                thumbnailURL: thumbnailURL,
                linkURL: videoURL,
                title: content.viewitTitle,
                text: content.viewitText,
                time: time,
                likedCount: content.likedNumber,
                isLiked: content.isLiked,
                isBlind: content.isBlind
            )
        }
    }
}

