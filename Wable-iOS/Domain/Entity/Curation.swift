//
//  Curation.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/21/25.
//

import Foundation

// MARK: - 큐레이션

struct Curation: Hashable, Identifiable {
    let id: Int
    let title: String
    let time: Date
    let url: URL
    let thumbnailURL: URL
}
