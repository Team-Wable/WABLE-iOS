//
//  RegisterResult.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Foundation

// MARK: - 커뮤니티 사전참여 (반환값)

extension DTO.Response {
    struct RegisterResult: Decodable {
        let registrationRate: Double
        
        enum CodingKeys: String, CodingKey {
            case registrationRate = "communityNum"
        }
    }
}
