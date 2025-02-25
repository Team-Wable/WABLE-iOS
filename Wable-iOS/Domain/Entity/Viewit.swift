//
//  Viewit.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/22/25.
//


import Foundation

// MARK: - 뷰잇 정보

struct Viewit {
    let userID: Int
    let viewitID: Int
    let userNickname: String
    let userProfileURL: URL?
    let thumbnailURL: URL?
    let linkURL: URL?
    let title: String
    let text: String
    let time: Date?
    let likedCount: Int
    let isLiked: Bool
    let isBlind: Bool
}
