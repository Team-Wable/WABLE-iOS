//
//  NotificationRouter.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/31/24.
//

import Foundation

import Moya

enum NotificationRouter {
    case getNotiInfo(param: Int)
    case getNotiActivity(param: Int)
    case getFeedTopInfo(param: Int)
}

extension NotificationRouter: BaseTargetType {
    var path: String {
        switch self {
        case .getNotiInfo:
            return StringLiterals.Endpoint.Notification.getNotiInfo
        case .getNotiActivity:
            return StringLiterals.Endpoint.Notification.getNotiActivity
        case .getFeedTopInfo(let contentID):
            return StringLiterals.Endpoint.Notification.getFeedInfo + "\(contentID)"

        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getNotiInfo:
            return .get
        case .getNotiActivity:
            return .get
        case .getFeedTopInfo:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getNotiInfo(let cursor):
            return .requestParameters(parameters: ["cursor": cursor], encoding: URLEncoding.queryString)
        case .getNotiActivity(let cursor):
            return .requestParameters(parameters: ["cursor": cursor], encoding: URLEncoding.queryString)
        case .getFeedTopInfo(param: let param):
            return .requestPlain
        }
    }
}

