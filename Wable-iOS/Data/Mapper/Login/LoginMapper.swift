//
//  LoginMapper.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/19/25.
//

import Foundation

enum LoginMapper { }

extension LoginMapper {
    static func tokenMapper(_ response: DTO.Response.UpdateToken) -> Token {
        return Token(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }
    
    static func accountMapper(_ response: DTO.Response.CreateAccount) -> Account {
        let url = URL(string: response.memberProfileURL)
        let fanTeam = LCKTeam(rawValue: response.memberFanTeam)
        
        return Account(
            user: User(
                id: response.memberID,
                nickname: response.nickName,
                profileURL: url,
                fanTeam: fanTeam
            ),
            token: Token(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            ),
            userLevel: response.memberLevel,
            lckYears: response.memberLCKYears,
            isAdmin: response.isAdmin,
            isPushAlarmAllowed: response.isPushAlarmAllowed,
            isNewUser: response.isNewUser
        )
    }
}
