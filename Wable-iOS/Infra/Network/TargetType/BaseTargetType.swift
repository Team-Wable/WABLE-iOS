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
    var multipartFormData: [MultipartFormData]? { get }
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
        } else if let multipartFormData {
            return .uploadMultipart(multipartFormData)
        }
        return .requestPlain
    }
    
    var validationType: ValidationType {
        return .none 
    }
    
    var headers: [String : String]? {
        guard multipartFormData != nil else {
            return ["Content-Type": "application/json"]
        }
        
        return ["Content-Type": "multipart/form-data"]
    }
}
