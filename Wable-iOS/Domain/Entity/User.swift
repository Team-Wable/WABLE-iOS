//
//  User.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/16/25.
//

import Foundation

// MARK: - 유저

struct User {
    let id: Int
    let nickname: String
    let profileURL: URL?
    let fanTeam: LCKTeam?
}
