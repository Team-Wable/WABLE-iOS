//
//  CreateContentLiked.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 게시물 좋아요 버튼

extension DTO.Request {
    struct CreateContentLiked: Encodable {
        let alarmTriggerType: String
    }
}
