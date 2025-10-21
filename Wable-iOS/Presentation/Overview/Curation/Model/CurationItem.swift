//
//  CurationItem.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/16/25.
//

import Foundation

struct CurationItem: Hashable, Identifiable {
    let id: Int
    let title: String
    let createdAt: String
    let siteName: String
    let url: URL
    let thumbnailURL: URL?
}
