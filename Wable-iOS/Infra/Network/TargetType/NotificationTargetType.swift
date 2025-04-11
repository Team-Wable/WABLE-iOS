//
//  NotificationTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Foundation

import Moya

enum NotificationTargetType {
    case fetchInfoNotifications(cursor: Int)
    case checkNotification
    case fetchUserNotifications(cursor: Int)
    case fetchUncheckedNotificationNumber
}

extension NotificationTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .fetchInfoNotifications:
            "/v1/notification/info"
        case .checkNotification:
            "/v1/information-check"
        case .fetchUserNotifications:
            "/v1/notifications"
        case .fetchUncheckedNotificationNumber:
            "/v1/notification/number"
        }
    }
    
    var query: [String : Any]? {
        switch self {
        case .fetchInfoNotifications(let cursor), .fetchUserNotifications(let cursor):
            return ["cursor": cursor]
        case .checkNotification, .fetchUncheckedNotificationNumber:
            return nil
        }
    }
    
    var requestBody: (any Encodable)? {
        return nil
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchInfoNotifications, .fetchUserNotifications, .fetchUncheckedNotificationNumber:
            return .get
        case .checkNotification:
            return .patch
        }
    }
}
