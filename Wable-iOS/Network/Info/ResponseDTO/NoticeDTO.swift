//
//  NoticeDTO.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/26/24.
//

import Foundation

struct NoticeDTO: Codable {
    let id: Int
    let title: String
    let text: String
    let imageURLString: String?
    let time: String
    
    enum CodingKeys: String, CodingKey {
        case id = "noticeId"
        case title = "noticeTitle"
        case text = "noticeText"
        case imageURLString = "noticeImage"
        case time
    }
}

extension NoticeDTO: Hashable {
    static func == (lhs: NoticeDTO, rhs: NoticeDTO) -> Bool {
        lhs.id == rhs.id
    }
}
