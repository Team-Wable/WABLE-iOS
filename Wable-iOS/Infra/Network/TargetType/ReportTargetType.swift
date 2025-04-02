//
//  ReportTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

import Moya

enum ReportTargetType {
    case createReport(request: DTO.Request.CreateReport)
    case createBan(request: DTO.Request.CreateBan)
}

extension ReportTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .createReport:
            return "/v1/report/slack"
        case .createBan:
            return "/v1/report/ban"
        }
    }
    
    var query: [String : Any]? {
        return .none
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .createReport(request: let request):
            return request
        case .createBan(request: let request):
            return request
        }
    }
    
    var method: Moya.Method {
        return .post
    }
}
