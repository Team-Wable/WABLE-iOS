//
//  ContentLikedTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

import Moya

enum ContentLikedTargetType {
    case createContentLiked(contentID: Int, request: DTO.Request.CreateContentLiked)
    case deleteContentLiked(contentID: Int)
}

extension ContentLikedTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .createContentLiked(contentID: let contentID, _):
            return "/v1/content/\(contentID)/liked"
        case .deleteContentLiked(contentID: let contentID):
            return "/v1/content/\(contentID)/unliked"
        }
    }
    
    var query: [String : Any]? {
        return .none
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .createContentLiked(_, request: let request):
            return request
        case .deleteContentLiked:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createContentLiked:
            return .post
        case .deleteContentLiked:
            return .delete
        }
    }
}
