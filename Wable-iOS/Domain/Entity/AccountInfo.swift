//
//  AccountInfo.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Foundation

// MARK: - 계정 정보

struct AccountInfo {
    let memberID: Int
    let createdDate: Date?
    let displayMemberID: String
    let socialPlatform: SocialPlatform?
    let version: String
}
