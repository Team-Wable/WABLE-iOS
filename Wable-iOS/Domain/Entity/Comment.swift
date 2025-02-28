//
//  Comment.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 댓글 핵심 정보

struct Comment {
    let author: User
    let id: Int
    let text: String
    let createdDate: Date?
    let isLiked: Bool
    let isGhost: Bool
    let isBlind: Bool?
    let ghostCount: Int
    let likedCount: Int
}

// MARK: - 유저가 작성한 댓글

struct UserComment {
    let comment: Comment
    let contentID: Int
}

// MARK: - 게시물 댓글

struct ContentComment {
    let comment: Comment    
    let parentID: Int
    let isDeleted: Bool
    let childs: [ContentComment]
}
