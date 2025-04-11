//
//  ViewitTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

import Moya

enum ViewitTargetType {
    case deleteViewit(viewitID: Int)
    case deleteViewitLiked(viewitID: Int)
    case createViewitLiked(viewitID: Int)
    case fetchViewitList(cursor: Int)
    case createViewitPost(request: DTO.Request.CreateViewitPost)
}

extension ViewitTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .deleteViewit(viewitID: let viewitID):
            return "~/api/v1/viewit/\(viewitID)"
        case .deleteViewitLiked(viewitID: let viewitID):
            return "~/api/v1/viewit/\(viewitID)/unliked"
        case .createViewitLiked(viewitID: let viewitID):
            return "/v1/viewit/\(viewitID)/liked"
        case .fetchViewitList:
            return "/v1/viewit"
        case .createViewitPost:
            return "/v1/viewit"
        }
    }
    
    var query: [String : Any]? {
        switch self {
        case .fetchViewitList(cursor: let cursor):
            return ["cursor" : cursor]
        default:
            return .none
        }
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .createViewitPost(request: let request):
            return request
        default:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .deleteViewit, .deleteViewitLiked:
            return .delete
        case .createViewitLiked, .createViewitPost:
            return .post
        case .fetchViewitList:
            return .get
        }
    }
}
