//
//  Content.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 게시물 리스트

struct Content: Hashable {
    let content: UserContent
    let isDeleted: Bool
}

struct UserContent: Identifiable, Hashable {
    let id: Int
    let contentInfo: ContentInfo
}

// MARK: - 게시물 상세 정보

struct ContentInfo: Hashable {
    let author: User
    let createdDate: Date?
    let title: String
    let imageURL: URL?
    let text: String
    
    var status: PostStatus
    var like: Like
    var opacity: Opacity
    var commentCount: Int
}
