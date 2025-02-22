//
//  DIContainer.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/15/25.
//

import Foundation

// MARK: - DependencyContainer

protocol DependencyRegistable {
    func register<T>(for type: T.Type, object: T)
    func register<T>(for type: T.Type, _ resolver: @escaping (DependencyResolvable) -> T)
    func unregister<T>(for type: T.Type)
}

protocol DependencyResolvable {
    func resolve<T>(for type: T.Type) -> T
}

typealias DependencyContainer = DependencyRegistable & DependencyResolvable

// MARK: - AppDIContainer

final class AppDIContainer {
    static let shared = AppDIContainer()
    
    private var dependencies = [String: Any]()
    
    private init() {}
}

extension AppDIContainer: DependencyContainer {
    func register<T>(for type: T.Type, object: T) {
        dependencies[key(type)] = object
    }
    
    func register<T>(for type: T.Type, _ resolver: @escaping (any DependencyResolvable) -> T) {
        dependencies[key(type)] = { [weak self] in
            guard let self else {
                fatalError("self is optional")
            }
            return resolver(self)
        }
    }
    
    func unregister<T>(for type: T.Type) {
        dependencies.removeValue(forKey: key(type))
    }
    
    func resolve<T>(for type: T.Type) -> T {
        let key = key(type)
        
        if let resolver = dependencies[key] as? (any DependencyResolvable) -> T {
            return resolver(self)
        } else if let object = dependencies[key] as? T {
            return object
        } else {
            fatalError("No dependency registered for \(key)")
        }
    }
    
    private func key<T>(_ type: T.Type) -> String {
        return String(describing: type)
    }
}
