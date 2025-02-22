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
    
    init() {
        self.dependency = AppDIContainer.shared.resolve(for: T.self)
    }
    
    var wrappedValue: T {
        get { dependency }
    }
}
