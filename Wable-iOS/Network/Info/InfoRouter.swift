//
//  InfoRouter.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/28/24.
//

import Foundation

import Moya

enum InfoRouter {
    case getMatchInfo
}

extension InfoRouter: BaseTargetType {
    var path: String {
        switch self {
        case .getMatchInfo:
            return StringLiterals.Endpoint.Info.getMatchInfo
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMatchInfo:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMatchInfo:
            return .requestPlain
        }
    }
}
