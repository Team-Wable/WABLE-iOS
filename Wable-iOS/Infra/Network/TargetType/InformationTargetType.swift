//
//  InformationTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Foundation

import Moya

enum InformationTargetType {
    case fetchGameSchedules
    case fetchGameCategory
    case fetchTeamRanks
    case fetchNewsNoticeNumber
    case fetchNews(cursor: Int)
    case fetchNotices(cursor: Int)
    case fetchCurations(cursor: Int)
}

extension InformationTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .fetchGameSchedules:
            "/v1/information/schedule"
        case .fetchGameCategory:
            "/v1/information/gametype"
        case .fetchTeamRanks:
            "/v1/information/rank"
        case .fetchNewsNoticeNumber:
            "/v1/information/number"
        case .fetchNews:
            "/v1/information/news"
        case .fetchNotices:
            "/v1/information/notice"
        case .fetchCurations:
            "/v1/information/curation"
        }
    }
    
    var query: [String : Any]? {
        switch self {
        case .fetchNews(let cursor), .fetchNotices(let cursor), .fetchCurations(let cursor):
            return ["cursor": cursor]
        default:
            return nil
        }
    }
    
    var requestBody: (any Encodable)? {
        return nil
    }
    
    var method: Moya.Method {
        return .get
    }
}
