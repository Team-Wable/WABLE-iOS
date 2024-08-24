//
//  BaseTargetType.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import Foundation
import Moya

protocol BaseTargetType: TargetType{ }

extension BaseTargetType{

    var baseURL: URL {

        let baseURL = Config.baseURL
        return URL(string: baseURL)!
    }

    var headers: [String : String]? {
        return APIConstants.hasTokenHeader
    }
}
