//
//  Content.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 게시물 정보

struct Content: Identifiable, Hashable, Likable {
    let id: Int
    let author: User
    let text: String
    let title: String
    let imageURL: URL?
    let isDeleted: Bool?
    let createdDate: Date?
    
    var isLiked: Bool
    var likeCount: Int
    var opacity: Opacity
    var commentCount: Int
    var status: PostStatus
}
