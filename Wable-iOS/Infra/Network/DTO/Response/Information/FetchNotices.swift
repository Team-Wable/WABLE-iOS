//
//  FetchNotice.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

extension DTO.Response {
    
    // MARK: - 공지사항 항목 데이터
    
    struct FetchNotices: Decodable {
        let noticeID: Int
        let noticeTitle: String
        let noticeText: String
        let noticeImageURL: String?
        let time: String
        
        enum CodingKeys: String, CodingKey {
            case noticeID = "noticeId"
            case noticeTitle
            case noticeText
            case noticeImageURL = "noticeImage"
            case time
        }
    }
}
