//
//  BaseTargetType.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/15/25.
//

import Foundation

import Moya

protocol BaseTargetType: TargetType {
    var endPoint: String? { get }
    var query: [String: Any]? { get }
    var requestBody: Encodable? { get }
}

extension BaseTargetType {
    var baseURL: URL {
        return Bundle.baseURL
    }
    
    var path: String {
        guard let url = endPoint else { return "" }
        
        return url
    }
    
    var task: Task {
        if let query {
            return .requestParameters(
                parameters: query,
                encoding: URLEncoding.default
            )
        } else if let requestBody {
            return .requestJSONEncodable(requestBody)
        }
        return .requestPlain
    }
    
    var validationType: ValidationType {
        return .none 
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
