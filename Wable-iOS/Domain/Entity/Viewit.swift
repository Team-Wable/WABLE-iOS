//
//  Viewit.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/22/25.
//


import Foundation

// MARK: - 뷰잇 정보

struct Viewit: Identifiable, Hashable {
    let userID: Int
    let userNickname: String
    let userProfileURL: URL?
    let id: Int
    let thumbnailURL: URL?
    let linkURL: URL?
    let title: String
    let text: String
    let time: Date?
    
    var status: PostStatus
    var like: Like
}
