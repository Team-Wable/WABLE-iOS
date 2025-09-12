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
        
        return response.map { viewit in
            let userProfileURL = URL(string: viewit.memberProfileURL)
            let thumbnailURL = URL(string: viewit.viewitImage ?? "")
            let videoURL = URL(string: viewit.viewitLink ?? "")
            let time = dateFormatter.date(from: viewit.time)
            
            let postStatus: PostStatus = viewit.isBlind ? .blind : .normal
            
            return Viewit(
                userID: viewit.memberID,
                userNickname: viewit.memberNickname,
                userProfileURL: userProfileURL,
                id: viewit.viewitID,
                thumbnailURL: thumbnailURL,
                siteURL: videoURL,
                siteName: viewit.viewitName,
                title: viewit.viewitTitle,
                text: viewit.viewitText,
                time: time,
                status: postStatus,
                isLiked: viewit.isLiked,
                likeCount: viewit.likedNumber
            )
        }
    }
}

