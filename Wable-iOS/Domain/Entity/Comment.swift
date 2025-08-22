//
//  Comment.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 댓글 정보

struct Comment: Identifiable, Hashable, Likable {
    let id: Int
    let author: User
    let text: String
    let contentID: Int
    let isDeleted: Bool?
    let createdDate: Date?
    let parentContentID: Int?
    let children: [Comment]
    
    var likeCount: Int
    var isLiked: Bool
    var opacity: Opacity
    var status: PostStatus
}
