//
//  Viewit.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/22/25.
//


import Foundation

// MARK: - 뷰잇 정보

struct Viewit: Identifiable, Hashable, Likable {
    let userID: Int
    let userNickname: String
    let userProfileURL: URL?
    let id: Int
    let thumbnailURL: URL?
    let siteURL: URL?
    let siteName: String?
    let title: String
    let text: String
    let time: Date?
    
    var status: PostStatus
    var isLiked: Bool
    var likeCount: Int
}
