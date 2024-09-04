//
//  CommentLikeRequestDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 9/4/24.
//

import Foundation

struct CommentLikeRequestDTO: Encodable {
    let notificationTriggerType: String
    let notificationText: String
}
