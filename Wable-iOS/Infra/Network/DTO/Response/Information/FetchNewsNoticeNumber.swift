//
//  FetchNewsNoticeNumber.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

extension DTO.Response {
    
    // MARK: - 뉴스 및 공지사항 개수 데이터
    
    struct FetchNewsNoticeNumber: Decodable {
        let newsNumber: Int
        let noticeNumber: Int
    }
}
