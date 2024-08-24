//
//  HomeRouter.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/22/24.
//

import Foundation

import Moya

enum HomeRouter {
    case getContent(param: Int)
}

extension HomeRouter: BaseTargetType {
    var path: String {
        switch self {
        case .getContent:
            return StringLiterals.Endpoint.Home.getContent
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getContent:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getContent(let cursor):
            return .requestParameters(parameters: ["cursor": cursor], encoding: URLEncoding.queryString)
        }
    }
}
