//
//  GhostTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Foundation

import Moya

enum GhostTargetType {
    case ghostReduction(request: DTO.Request.UpdateGhost)
}

extension GhostTargetType: BaseTargetType {
    var endPoint: String? {
        switch self {
        case .ghostReduction:
            return "/v1/ghost2"
        }
    }
    
    var query: [String : Any]? {
        switch self {
        case .ghostReduction:
            return nil
        }
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .ghostReduction(let request):
            return request
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .ghostReduction:
            return .post
        }
    }
}
