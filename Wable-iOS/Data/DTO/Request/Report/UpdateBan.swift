//
//  UpdateBan.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/20/25.
//


import Foundation

// MARK: - 밴하기 기능

extension DTO.Request {
    struct UpdateBan {
        let memberID: Int
        let triggerType: String
        let triggerID: Int
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case triggerType
            case triggerID = "triggerId"
        }
    }
}
