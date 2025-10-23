//
//  FetchCurationList.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/19/25.
//

import Foundation

extension DTO.Response {

    // MARK: - 큐레이션 목록 조회

    struct FetchCurationList: Decodable {
        let id: Int
        let title: String?
        let createdAt: String
        let urlString: String
        let thumbnailURLString: String?

        enum CodingKeys: String, CodingKey {
            case id = "curationId"
            case title = "curationTitle"
            case createdAt = "time"
            case urlString = "curationLink"
            case thumbnailURLString = "curationThumbnail"
        }
    }
}
