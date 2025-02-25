//
//  CreateCommentLiked.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 답글 좋아요 버튼

extension DTO.Request {
    struct CreateCommentLiked: Encodable {
        let notificationTriggerType: String
        let notificationText: String
        
        enum CodingKeys: String, CodingKey {
            case notificationTriggerType
            case notificationText
        }
    }
}
