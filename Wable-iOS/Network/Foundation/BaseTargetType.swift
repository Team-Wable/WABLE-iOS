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
        // config 파일 생성 후 주석 해제
//        let baseURL = Bundle.main.infoDictionary?["BASE_URL"] as? String ?? ""
        let baseURL = "https://sample.base.url"
        return URL(string: baseURL)!
    }

    var headers: [String : String]? {
        return APIConstants.hasTokenHeader
    }
}
