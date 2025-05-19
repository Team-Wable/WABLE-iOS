//
//  ActivityNotification+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/30/25.
//

import Foundation

extension ActivityNotification {
    var message: String {
        guard let type else {
            return "알 수 없는 메세지"
        }
        
        switch type {
        case .contentLike:
            return "\(triggerUserNickname)님이 \(userNickname)님의 게시물을 좋아합니다."
        case .commentLike:
            return "\(triggerUserNickname)님이 \(userNickname)님의 댓글을 좋아합니다."
        case .comment:
            return "\(triggerUserNickname)님이 댓글을 작성했습니다."
        case .contentGhost:
            return "\(userNickname)님, 작성하신 게시글로 인해 점점 투명해지고 있어요."
        case .commentGhost:
            return "\(userNickname)님, 작성하신 댓글로 인해 점점 투명해지고 있어요."
        case .beGhost:
            return "\(userNickname)님, 투명해져서 당분간 글을 작성할 수 없어요."
        case .actingContinue:
            return "\(userNickname)님, 이제 글을 다시 작성할 수 있어요! 오랜만에 와블에 인사를 남겨주세요!"
        case .userBan:
            return "\(userNickname)님, 신고가 누적되어 작성하신 글이 블라인드 처리되었습니다. 자세한 내용은 문의사항으로 남겨주세요."
        case .popularWriter:
            return "\(userNickname)님이 작성하신 글이 인기글로 선정 되었어요!🥳🥳"
        case .popularContent:
            return "어제 가장 인기있던 글이에요."
        case .childComment:
            return "\(triggerUserNickname)님이 \(userNickname)님에게 대댓글을 작성했습니다."
        case .childCommentLike:
            return "\(triggerUserNickname)님이 \(userNickname)님의 대댓글을 좋아합니다."
        case .viewitLike:
            return "\(triggerUserNickname)님이 \(userNickname)님의 추천 링크를 좋아합니다."
        }
    }
}
