//
//  Account.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 계정

struct Account {
    let user: User
    let token: Token
    let userLevel: Int
    let lckYears: Int
    let isAdmin: Bool
    let isPushAlarmAllowed: Bool?
    let isNewUser: Bool
}
