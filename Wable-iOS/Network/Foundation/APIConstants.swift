//
//  APIConstants.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import Foundation
import Moya

struct APIConstants {

    static let contentType = "Content-Type"
    static let applicationJSON = "application/json"
    static let multipartFormData = "multipart/form"
    static let auth = "Authorization"
    static let refresh = "RefreshToken"
    static var accessToken = "Bearer \(KeychainWrapper.loadToken(forKey: "accessToken") ?? "")"
}

extension APIConstants{

    static var noTokenHeader: Dictionary<String,String> {
        [contentType: applicationJSON]
    }

    static var hasTokenHeader: Dictionary<String,String> {
        [
            contentType: applicationJSON,
            auth : accessToken
        ]
    }
    
    static var multipartHeader: Dictionary<String, String> {
        [
            contentType: multipartFormData,
            auth: accessToken
        ]
    }
    
    static func loginHeader(accessToken: String) -> Dictionary<String,String> {
        return [
            contentType: applicationJSON,
            auth :  "Bearer \(accessToken)"
        ]
    }
}
