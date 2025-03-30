//
//  Bundle+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Foundation

extension Bundle {
    static let identifier: String = {
        guard let identifierString = main.bundleIdentifier else {
            fatalError("Bundle identifier를 찾을 수 없습니다.")
        }
        
        return identifierString
    }()
    
    static let baseURL: URL = {
        guard let urlString = main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString)
        else {
            fatalError("BASE_URL을 찾을 수 없습니다.")
        }
        
        return url
    }()
    
    static let kakaoAppKey: String = {
        guard let key = main.object(forInfoDictionaryKey: "NATIVE_APP_KEY") as? String else {
            fatalError("NATIVE_APP_KEY를 찾을 수 없습니다.")
        }
        
        return key
    }()
    
    static let amplitudeAppKey: String = {
        guard let key = main.object(forInfoDictionaryKey: "AMPLITUDE_APP_KEY") as? String else {
            fatalError("AMPLITUDE_APP_KEY를 찾을 수 없습니다.")
        }
        
        return key
    }()
}
