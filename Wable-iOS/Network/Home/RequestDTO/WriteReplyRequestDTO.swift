//
//  WriteReplyRequestDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/30/24.
//

import Foundation
import UIKit

// MARK: - 댓글 작성

struct WriteReplyRequestDTO: Encodable {
    let commentText: String
    let notificationTriggerType: String
}

// MARK: - 1.1.0v DTO

struct WriteReplyRequestV3DTO: Encodable {
    let commentText: String
    let parentCommentID: Int
    let parentCommentWriterID: Int
    
    enum CodingKeys: String, CodingKey {
        case commentText
        case parentCommentID = "parentCommentId"
        case parentCommentWriterID = "parentCommentWriterId"
    }
}
