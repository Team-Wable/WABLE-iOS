//
//  Injected.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/15/25.
//

import Foundation

@propertyWrapper
struct Injected<T> {
    private var dependency: T
    
    init(env: AppEnvironment = .production) {
        self.dependency = AppDIContainer.shared.resolve(for: T.self, env: env)
    }
    
    var wrappedValue: T {
        get { dependency }
    }
}
