//
//  TriggerType.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation


enum TriggerType {
    
    // MARK: - 유저 활동 알림에 대한 종류

    enum ActivityNotification: String {
        case contentLike = "contentLiked"
        case commentLike = "commentLiked"
        case comment = "comment"
        case contentGhost = "contentGhost"
        case commentGhost = "commentGhost"
        case beGhost = "beGhost"
        case actingContinue = "actingContinue"
        case userBan = "userBan"
        case popularWriter = "popularWriter"
        case popularContent = "popularContent"
        case childComment = "childComment"
        case childCommentLike = "childCommentLiked"
        case viewitLike = "viewitLiked"
        
        static func from(_ value: String) -> Self? {
            if let result = Self(rawValue: value) {
                return result
            }
            
            WableLogger.log("\(String(describing: Self.self))생성 실패: \(value)", for: .debug)
            return nil
        }
    }
    
    // MARK: - 투명도 낮추기에 대한 종류
    
    enum Ghost: String {
        case commentGhost = "commentGhost"
        case contentGhost = "contentGhost"
    }

    // MARK: - 좋아요 누르기에 대한 종류
    
    enum Like: String {
        case commentLike = "commentLiked"
        case contentLike = "contentLiked"
    }

    // MARK: - 밴하기에 대한 종류
    
    enum Ban: String {
        case content = "content"
        case comment = "comment"
        case viewit = "viewit"
    }
}
