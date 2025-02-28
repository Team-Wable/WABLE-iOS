//
//  Content.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 게시물 리스트

struct Content {
    let content: UserContent
    let isDeleted: Bool
}

struct UserContent {
    let id: Int
    let contentInfo: ContentInfo
}

// MARK: - 게시물 상세 정보

struct ContentInfo {
    let author: User
    let createdDate: Date?
    let title: String
    let imageURL: URL?
    let text: String
    let ghostCount: Int
    let isLiked: Bool
    let isGhost: Bool
    let isBlind: Bool?
    let likedCount: Int
    let commentCount: Int
}
