//
//  UpdateToken.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 토큰 재발급

extension DTO.Response {
    struct UpdateToken: Decodable {
        let accessToken: String
        let refreshToken: String
    }
}
