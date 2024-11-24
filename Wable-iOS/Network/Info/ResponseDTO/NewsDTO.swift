//
//  NewsDTO.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import Foundation

struct NewsDTO: Codable {
    let id: Int
    let title: String
    let text: String
    let imageURLString: String
    let time: String
    
    enum CodingKeys: String, CodingKey {
        case id = "newsId"
        case title = "newsTitle"
        case text = "newsText"
        case imageURLString = "newsImage"
        case time
    }
}
