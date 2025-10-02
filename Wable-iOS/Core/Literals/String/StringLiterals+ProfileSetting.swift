//
//  StringLiterals+Profile.swift
//  Wable-iOS
//
//  Created by YOUJIM on 5/27/25.
//


import Foundation

extension StringLiterals {
    
    // MARK: - ProfileSetting

    enum ProfileSetting {
        static let registerTitle = "와블에서 활동할\n프로필을 등록해 주세요"
        static let registerDescription = "프로필 사진은 나중에도 등록 가능해요"
        static let editTitle = "와블에서 멋진 모습으로\n활동해 보세요!"
        static let checkDefaultMessage = "10자리 이내, 문자/숫자로 입력 가능해요"
        static let checkInvaildError = "닉네임에 사용할 수 없는 문자가 포함되어 있어요."
        static let checkDuplicateError = "이미 사용 중인 닉네임입니다."
        static let checkVaildMessage = "사용 가능한 닉네임입니다."
        static let nicknamePattern = "^[ㄱ-ㅎ가-힣a-zA-Z0-9]+$"
    }
}
