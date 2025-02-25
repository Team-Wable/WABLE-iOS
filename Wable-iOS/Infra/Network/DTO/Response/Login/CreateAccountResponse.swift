//
//  CreateAccount.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 소셜 로그인 및 회원가입

extension DTO.Response {
    struct CreateAccount: Decodable {
        let nickName: String
        let memberID: Int
        let accessToken, refreshToken: String
        let memberProfileURL: String
        let isNewUser: Bool
        let isPushAlarmAllowed: Bool?
        let memberFanTeam: String
        let memberLCKYears, memberLevel: Int
        let isAdmin: Bool
        
        enum CodingKeys: String, CodingKey {
            case nickName
            case memberID = "memberId"
            case accessToken, refreshToken
            case memberProfileURL = "memberProfileUrl"
            case isNewUser, isPushAlarmAllowed, memberFanTeam
            case memberLCKYears = "memberLckYears"
            case memberLevel, isAdmin
        }
    }
}
