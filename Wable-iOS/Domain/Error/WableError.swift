//
//  WableError.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/25/25.
//

import Foundation

enum WableError: String, Error {
    
    // MARK: - 명세서에 명시된 오류

    case validationException = "잘못된 요청입니다."
    case validationRequestMissing = "요청값이 입력되지 않았습니다."
    case noToken = "토큰을 넣어주세요."
    case invalidMember = "유효하지 않은 유저입니다."
    case anotherAccessToken = "지원하지 않는 소셜 플랫폼입니다."
    case duplicationContentLike = "이미 좋아요를 누른 게시물입니다."
    case unexistContentLike = "좋아요를 누르지 않은 게시물입니다."
    case ghostHighLimit = "투명도는 0이상일 수 없습니다."
    case duplicationCommentLike = "이미 좋아요를 누른 답글입니다."
    case unexistCommentLike = "좋아요를 누르지 않은 답글입니다."
    case duplicationMemberGhost = "이미 투명도를 누른 대상입니다."
    case nicknameValidateError = "이미 존재하는 닉네임입니다."
    case ghostMyselfBlock = "본인의 투명도를 내릴 수 없습니다."
    case ghostUser = "투명도가 -85이하라서 글이나 답글을 작성할 수 없습니다."
    case withdrawalMember = "계정 삭제 후 30일 이내 회원입니다."
    case unvalidProfileImageType = "이미지 확장자는 jpg, png, webp만 가능합니다."
    case profileImageDataSize = "이미지 사이즈는 5MB를 넘을 수 없습니다."
    case fcmServiceError = "푸시 알림 발생 과정에 오류가 생겼습니다."
    case notFoundMember = "해당하는 유저가 없습니다."
    case notFoundContent = "해당하는 게시물이 없습니다."
    case notFoundComment = "해당하는 답글이 없습니다."
    case unauthorizedMember = "권한이 없는 유저입니다."
    case unauthorizedToken = "유효하지 않은 토큰입니다."
    case kakaoUnauthorizedUser = "카카오 로그인 실패. 만료되었거나 잘못된 카카오 토큰입니다."
    case failedToValidateAppleLogin = "애플 로그인 실패. 만료되었거나 잘못된 애플 토큰입니다."
    case signinRequired = "access, refreshToken 모두 만료되었습니다. 재로그인이 필요합니다."
    case validAccessToken = "아직 유효한 accessToken 입니다."
    
    // MARK: - 명세서에 존재하지 않는 오류

    case networkError = "네트워크 오류가 발생했습니다."
    case unknownError = "알 수 없는 오류가 발생했습니다."
    
    var localizedDescription: String {
        return self.rawValue
    }
}
