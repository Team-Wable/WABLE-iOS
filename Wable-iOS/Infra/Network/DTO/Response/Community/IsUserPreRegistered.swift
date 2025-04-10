//
//  IsUserPreRegistered.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Foundation

// MARK: - 사용자 참여 커뮤니티 확인

extension DTO.Response {
    struct IsUserPreRegistered: Decodable {
        let commnunityName: String?
    }
}
