//
//  UserRole.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Foundation

// MARK: - 컨텐츠(글, 댓글, 뷰잇 등)에 대한 사용자가 가질 수 있는 역할 - 바텀 시트와 연관

enum UserRole {
    case admin // 관리자
    case owner // 내 컨텐츠
    case viewer // 다른 사람 컨텐츠
}
