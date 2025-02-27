//
//  OAuthCredential.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/25/25.
//


import Foundation

import Alamofire

/// 앱 실행 시 토큰 캐싱을 위해 사용하는 Credential 구조체입니다.
struct OAuthCredential: AuthenticationCredential {
    let accessToken: String
    let refreshToken: String
    var requiresRefresh: Bool = false
}
