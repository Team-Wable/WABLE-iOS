//
//  CommentLikedTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

import Moya

enum CommentLikedTargetType {
    case createCommentLiked(commentID: Int, request: DTO.Request.CreateCommentLiked)
    case deleteCommentLiked(commentID: Int)
}

extension CommentLikedTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .createCommentLiked(contentID: let contentID):
            return "v1/comment/\(contentID)/liked"
        case .deleteCommentLiked(commentID: let commentID):
            return "v1/comment/\(commentID)/unliked"
        }
    }
    
    var query: [String : Any]? {
        return .none
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .createCommentLiked(commentID: _, request: let request):
            return request
        default:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createCommentLiked:
            return .post
        case .deleteCommentLiked:
            return .delete
        }
    }
    
    
}
