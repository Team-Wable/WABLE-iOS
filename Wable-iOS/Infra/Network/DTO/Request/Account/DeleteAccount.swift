//
//  DeleteAccount.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 계정 삭제

extension DTO.Request {
    struct DeleteAccount: Encodable {
        let deletedReason: [String]
        
        enum CodingKeys: String, CodingKey {
            case deletedReason = "deleted_reason"
        }
    }
}
