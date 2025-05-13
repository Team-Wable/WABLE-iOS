//
//  WithdrawalReason.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 계정 삭제 이유

enum WithdrawalReason: String {
    case inappropriateContent = "온화하지 못한 내용이 많이 보여요."
    case noDesiredContent = "원하는 콘텐츠가 없어요."
    case missingCommunityFeatures = "필요한 커뮤니티 기능이 없어요."
    case infrequentUse = "자주 사용하지 않아요."
    case appIssues = "앱 오류가 있어 사용하기 불편해요."
    case changingSocialAccount = "가입할 때 사용한 소셜 계정이 바뀔 예정이에요."
    case other = "기타"
}
