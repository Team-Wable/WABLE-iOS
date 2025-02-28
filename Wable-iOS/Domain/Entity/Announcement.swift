//
//  Announcement.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 뉴스 & 공지사항

struct Announcement: Identifiable, Hashable {
    let id: Int
    let title: String
    let imageURL: URL?
    let text: String
    let createdDate: Date?
}
