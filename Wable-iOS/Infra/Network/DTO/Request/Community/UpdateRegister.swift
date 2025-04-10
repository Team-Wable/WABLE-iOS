//
//  UpdateRegister.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/20/25.
//


import Foundation

// MARK: - 커뮤니티 사전 참여

extension DTO.Request {
    struct UpdateRegister: Encodable {
        let communityName: String
    }
}
