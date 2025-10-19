//
//  FetchCurations.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/19/25.
//

import Foundation

extension DTO.Response {

    // MARK: - 큐레이션 목록 조회

    struct FetchCurations: Decodable {
        let id: Int
        let urlString: String
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id = "curationId"
            case urlString = "curationLink"
            case createdAt = "time"
        }
    }
}
