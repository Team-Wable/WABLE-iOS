//
//  PostStatus.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/1/25.
//

import Foundation

// MARK: - 게시물, 댓글의 3가지 상태 (노말, 고스트, 블라인드) + 뷰잇의 2가지 상태 (노말, 블라인드)

enum PostStatus {
    case normal
    case ghost
    case blind
}
