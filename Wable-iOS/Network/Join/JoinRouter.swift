//
//  JoinRouter.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/8/25.
//

import Foundation

import Moya

enum JoinRouter {
    case getIsDuplicatedNickname(nickname: String)
    case patchUserProfile(requestBody: UserInfoDTO)
}

extension JoinRouter: BaseTargetType {
    var path: String {
        switch self {
        case .getIsDuplicatedNickname:
            return StringLiterals.Endpoint.Join.getIsDuplicatedNickname
        case .patchUserProfile:
            return StringLiterals.Endpoint.Join.patchUserProfile
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getIsDuplicatedNickname:
            return .get
        case .patchUserProfile:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getIsDuplicatedNickname(let nickname):
            return .requestParameters(
                parameters: ["nickname": nickname],
                encoding: URLEncoding.queryString
            )
            
        case .patchUserProfile(let requestBody):
            var multipartData: [MultipartFormData] = []
            
            if let imageData = requestBody.file {
                let fileData = MultipartFormData(
                    provider: .data(imageData),
                    name: "file",
                    fileName: "dontbe.jpeg",
                    mimeType: "image/jpeg"
                )
                multipartData.append(fileData)
            }

            if let jsonData = try? JSONEncoder().encode(requestBody) {
                let infoData = MultipartFormData(
                    provider: .data(jsonData),
                    name: "info",
                    mimeType: "application/json"
                )
                multipartData.append(infoData)
            }
            return .uploadMultipart(multipartData)
        }
    }

    
    var headers: [String : String]? {
        switch self {
        case .getIsDuplicatedNickname, .patchUserProfile:
            return APIConstants.hasTokenHeader
        }
    }
    
}
