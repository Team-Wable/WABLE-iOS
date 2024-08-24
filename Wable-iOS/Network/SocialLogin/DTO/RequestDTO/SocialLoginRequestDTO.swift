//
//  SocialLoginRequestDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation

// MARK: - SocialLoginRequestDTO

struct SocialLoginRequestDTO: Encodable {
    let socialPlatform: String
    let userName: String?
}
