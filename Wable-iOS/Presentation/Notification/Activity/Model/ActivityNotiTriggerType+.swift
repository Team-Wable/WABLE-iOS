//
//  ActivityNotiTriggerType+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/30/25.
//

import Foundation

extension TriggerType.ActivityNotification {
    /// 알림 셀에서 프로필 이미지 뷰를 눌렀을 때, 상호작용이 필요한 경우를 정의합니다.
    ///
    /// 이 Set에 포함된 알림 유형들은 사용자가 프로필 이미지를 탭했을 때
    /// 해당 사용자의 프로필로 이동하거나 추가 정보를 표시하는 등의
    /// 인터랙션이 필요한 알림 유형들입니다.
    ///
    /// - 포함된 알림 유형:
    ///   - `.commentLike`: 댓글에 좋아요를 받은 경우
    ///   - `.contentLike`: 게시물에 좋아요를 받은 경우
    ///   - `.comment`: 게시물에 댓글을 받은 경우
    ///   - `.childComment`: 댓글에 대댓글을 받은 경우
    ///   - `.childCommentLike`: 대댓글에 좋아요를 받은 경우
    ///
    /// - Note: 이 Set에 포함되지 않은 알림 유형(예: 시스템 알림)은
    ///   프로필 이미지 탭 시 아무런 동작을 수행하지 않습니다.
    static let profileInteractionTypes: Set<TriggerType.ActivityNotification> = [
        .commentLike,
        .contentLike,
        .comment,
        .childComment,
        .childCommentLike
    ]
}
