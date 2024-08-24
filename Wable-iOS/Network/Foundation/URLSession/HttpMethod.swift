//
//  HttpMethod.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation

enum HttpMethod {
    case get
    case post
    case delete
    case patch
    
    var method: String {
        switch self {
        case .get:
            "GET"
        case .post:
            "POST"
        case .delete:
            "DELETE"
        case .patch:
            "PATCH"
        }
    }
}
