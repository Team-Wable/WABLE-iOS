//
//  AppVersion.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/29/25.
//

import Foundation

struct AppVersion {
    let major: Int
    let minor: Int
    let patch: Int
    
    init(from versionString: String) {
        let components = versionString
            .split(separator: ".")
            .compactMap { Int($0) }
        
        self.major = components.count > 0 ? components[0] : 0
        self.minor = components.count > 1 ? components[1] : 0
        self.patch = components.count > 2 ? components[2] : 0
    }
}
