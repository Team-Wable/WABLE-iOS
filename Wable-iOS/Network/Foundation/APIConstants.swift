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
    static var accessToken = KeychainWrapper.loadToken(forKey: "accessToken")
//    static var accessToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjQyNTg3NjksImV4cCI6NTMyNDI1ODc2OSwibWVtYmVySWQiOjZ9.KcOdy_EaMYB7p4cMFYXMm8bQE2VXyragl79rpn3_zIo"
}

extension APIConstants{

    static var noTokenHeader: Dictionary<String,String> {
        [contentType: applicationJSON]
    }

    static var hasTokenHeader: Dictionary<String,String> {
        [contentType: applicationJSON,
               auth : "Bearer \(accessToken ?? "")"]
    }
}
