//
//  ContentTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

import Moya

enum ContentTargetType {
    case createContent(request: DTO.Request.CreateContent)
    case deleteContent(contentID: Int)
    case fetchContentInfo(contentID: Int)
    case fetchContentList(cursor: Int)
    case fetchUserContentList(memberID: Int, cursor: Int)
}

extension ContentTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        switch self {
        case .createContent(request: let request):
            var multipartFormData: [MultipartFormData] = []
            
            let parameters: [String: Any] = [
                "contentTitle": request.text.contentTitle,
                "contentText": request.text.contentText
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
                let textData = MultipartFormData(
                    provider: .data(jsonData),
                    name: "text"
                )
                
                multipartFormData.append(textData)
            }
            
            if let imageData = request.image {
                let imageFormData = MultipartFormData(
                    provider: .data(imageData),
                    name: "image",
                    fileName: "dontbe.jpeg",
                    mimeType: "image/jpeg"
                )
                
                multipartFormData.append(imageFormData)
            }
            
            return multipartFormData
        default:
            return .none
        }
    }
    
    var endPoint: String? {
        switch self {
        case .createContent:
            return "/v2/content"
        case .deleteContent(contentID: let contentID):
            return "/v1/content/\(contentID)"
        case .fetchContentInfo(contentID: let contentID):
            return "/v3/content/\(contentID)"
        case .fetchContentList:
            return "/v3/contents"
        case .fetchUserContentList(memberID: let memberID, _):
            return "/v3/member/\(memberID)/contents"
        }
    }
    
    var query: [String : Any]? {
        switch self {
        case .fetchContentList(cursor: let cursor):
            return ["cursor" : cursor]
        case .fetchUserContentList(_, cursor: let cursor):
            return ["cursor" : cursor]
        default:
            return .none
        }
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        default:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createContent:
            return .post
        case .deleteContent:
            return .delete
        case .fetchContentInfo, .fetchContentList, .fetchUserContentList:
            return .get
        }
    }
}
