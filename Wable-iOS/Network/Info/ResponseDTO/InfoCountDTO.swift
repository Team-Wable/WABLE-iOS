//
//  InfoCountDTO.swift
//  Wable-iOS
//
//  Created by 김진웅 on 1/7/25.
//

import Foundation

struct InfoCountDTO: Codable {
    let newsCount: Int
    let noticeCount: Int
    
    enum CodingKeys: String, CodingKey {
        case newsCount = "newsNumber"
        case noticeCount = "noticeNumber"
    }
}
