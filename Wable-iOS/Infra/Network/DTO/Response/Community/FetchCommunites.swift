//
//  FetchCommunites.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/20/25.
//


import Foundation

// MARK: - 커뮤니티 목록 조회 (사전 참여)

extension DTO.Response {
    struct FetchCommunites: Decodable {
        let communityName: String
        let registrationRate: Double
        
        enum CodingKeys: String, CodingKey {
            case communityName
            case registrationRate = "communityNum"
        }
    }
}
