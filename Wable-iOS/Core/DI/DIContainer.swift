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
    func register<T>(for type: T.Type, _ resolver: @escaping (AppEnvironment) -> T)
    func unregister<T>(for type: T.Type)
}

protocol DependencyResolvable {
    func resolve<T>(for type: T.Type, env: AppEnvironment) -> T
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
    
    func register<T>(for type: T.Type, _ resolver: @escaping (AppEnvironment) -> T) {
        dependencies[key(type)] = resolver
    }
    
    func unregister<T>(for type: T.Type) {
        dependencies.removeValue(forKey: key(type))
    }
    
    func resolve<T>(for type: T.Type, env: AppEnvironment) -> T {
        let key = key(type)
        
        if env == .production,
           let object = dependencies[key] as? T {
            return object
        }
        
        if let resolver = dependencies[key] as? (AppEnvironment) -> T {
            return resolver(env)
        }
        
        fatalError("No dependency registered for \(key) in \(env)")
    }
    
    private func key<T>(_ type: T.Type) -> String {
        return String(describing: type)
    }
}
