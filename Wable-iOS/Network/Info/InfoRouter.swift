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
    case getGameType
    case getTeamRank
    case getNews(param: Int)
}

extension InfoRouter: BaseTargetType {
    var path: String {
        switch self {
        case .getMatchInfo:
            return StringLiterals.Endpoint.Info.getMatchInfo
        case .getGameType:
            return StringLiterals.Endpoint.Info.getGameType
        case .getTeamRank:
            return StringLiterals.Endpoint.Info.getTeamRank
        case .getNews:
            return StringLiterals.Endpoint.Info.getNews
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMatchInfo, .getGameType, .getTeamRank, .getNews:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMatchInfo, .getGameType, .getTeamRank:
            return .requestPlain
        case .getNews(let cursor):
            return .requestParameters(parameters: ["cursor": cursor], encoding: URLEncoding.queryString)
        }
    }
}
