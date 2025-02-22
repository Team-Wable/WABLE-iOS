//
//  TriggerType.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 투명도 낮추기에 대한 종류

enum GhostTriggerType: String {
    case commentGhost = "commentGhost"
    case contentGhost = "contentGhost"
}

// MARK: - 좋아요 누르기에 대한 종류

enum LikeTriggerType: String {
    case commentLike = "commentLiked"
    case contentLike = "contentLiked"
}
