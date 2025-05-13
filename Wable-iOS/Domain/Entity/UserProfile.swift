//
//  UserProfile.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 유저 프로필

struct UserProfile: Hashable {
    let user: User
    let introduction: String
    let ghostCount: Int
    let lckYears: Int
    let userLevel: Int
}
