//
//  NotiActivityText.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/31/24.
//

import Foundation

enum NotiActivityText: String {
    case contentLiked = "contentLiked"
    case commentLiked = "commentLiked"
    case comment = "comment"
    case contentGhost = "contentGhost"
    case commentGhost = "commentGhost"
    case beGhost = "beGhost"
    case actingContinue = "actingContinue"
    case userBan = "userBan"
    case popularWriter = "popularWriter"
    case popularContent = "popularContent"
    
    func text(from triggerNickname: String, to userNickname: String) -> String {
        switch self {
        case .contentLiked:
            return "\(triggerNickname)님이 \(userNickname)님의 게시물을 좋아합니다"
        case .commentLiked:
            return "\(triggerNickname)님이 \(userNickname)님의 댓글을 좋아합니다"
        case .comment:
            return "\(triggerNickname)님이 댓글을 작성했습니다"
        case .contentGhost:
            return "\(userNickname)님, 작성하신 게시글로 인해 점점 투명해지고 있어요."
        case .commentGhost:
            return "\(userNickname)님, 작성하신 댓글로 인해 점점 투명해지고 있어요."
        case .beGhost:
            return "\(userNickname)님, 투명해져서 당분간 글을 작성할 수 없어요."
        case .actingContinue:
            return "\(userNickname)님, 이제 다시 글을 작성할 수 있어요! 오랜만에 돈비에 인사를 남겨주세요!"
        case .userBan:
            return "\(userNickname)님, 커뮤니티 활동 정책 위반으로 더 이상 와블을 사용할 수 없어요. 자세한 내용은 문의사항으로 남겨주세요"
        case .popularWriter:
            return "어제 가장 인기있던 글이에요."
        case .popularContent:
            return "\(userNickname)님이 작성하신 글이 인기글로 선정 되었어요🥳🥳"
        }
    }
}
