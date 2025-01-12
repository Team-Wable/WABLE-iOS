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
    case getNotice(param: Int)
    case getInfoCount
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
        case .getNotice:
            return StringLiterals.Endpoint.Info.getNotice
        case .getInfoCount:
            return StringLiterals.Endpoint.Info.getInfoCount
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMatchInfo, .getGameType, .getTeamRank, .getNews, .getNotice, .getInfoCount:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMatchInfo, .getGameType, .getTeamRank, .getInfoCount:
            return .requestPlain
        case .getNews(let cursor), .getNotice(let cursor):
            return .requestParameters(parameters: ["cursor": cursor], encoding: URLEncoding.queryString)
        }
    }
}
