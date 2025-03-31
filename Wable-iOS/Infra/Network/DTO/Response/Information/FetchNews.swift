//
//  FetchNews.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

extension DTO.Response {
    
    // MARK: - 뉴스 항목 데이터
    
    struct FetchNews: Decodable {
        let newsID: Int
        let newsTitle: String
        let newsText: String
        let newsImageURL: String?
        let time: String
        
        enum CodingKeys: String, CodingKey {
            case newsID = "newsId"
            case newsTitle
            case newsText
            case newsImageURL = "newsImage"
            case time
        }
    }
}
