//
//  Bundle+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Foundation

extension Bundle {
    static let baseURL: URL = {
        guard let urlString = main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString)
        else {
            fatalError("BaseURL을 찾을 수 없습니다.")
        }
        
        return url
    }()
}
