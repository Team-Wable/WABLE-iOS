//
//  CommentTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

import Moya

enum CommentTargetType {
    case fetchUserCommentList(memberID: Int, cursor: Int)
    case fetchContentCommentList(contentID: Int, cursor: Int)
    case deleteComment(commentID: Int)
    case createComment(contentID: Int, request: DTO.Request.CreateComment)
}

extension CommentTargetType: BaseTargetType {
    var endPoint: String? {
        switch self {
        case .fetchUserCommentList(memberID: let memberID):
            return "/v3/member/\(memberID)/member-comments"
        case .fetchContentCommentList(contentID: let contentID):
            return "/v3/content/\(contentID)/comments?cursor=277"
        case .deleteComment(commentID: let commentID):
            return "/v1/comment/\(commentID)"
        case .createComment(contentID: let contentID):
            return "/api/v3/content/\(contentID)/comment"
        }
    }
    
    var query: [String : Any]? {
        switch self {
        case .fetchUserCommentList(memberID: _, cursor: let cursor):
            return ["cursor" : cursor]
        case .fetchContentCommentList(contentID: _, cursor: let cursor):
            return ["cursor" : cursor]
        default:
            return .none
        }
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .createComment(contentID: _, request: let request):
            return request
        default:
            return .none
        }
    
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchUserCommentList, .fetchContentCommentList:
            return .get
        case .deleteComment:
            return .delete
        case .createComment:
            return .post
        }
    }
}
