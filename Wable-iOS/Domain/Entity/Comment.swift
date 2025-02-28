//
//  Comment.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 댓글 핵심 정보

struct Comment: Identifiable, Hashable {
    let author: User
    let id: Int
    let text: String
    let createdDate: Date?
    
    var status: PostStatus
    var like: Like
    var opacity: Opacity
}

// MARK: - 유저가 작성한 댓글

struct UserComment: Hashable {
    let comment: Comment
    let contentID: Int
}

// MARK: - 게시물 댓글

struct ContentComment: Hashable {
    let comment: Comment    
    let parentID: Int
    let isDeleted: Bool
    let childs: [ContentComment]
}
