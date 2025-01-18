//
//  UserDefaultsManager.swift
//  Wable-iOS
//
//  Created by 김진웅 on 1/7/25.
//

import Foundation

protocol UserDefaultsManager {
    func save<T: Codable>(_ value: T, forKey key: any UserDefaultsKey)
    func load<T: Codable>(forKey key: any UserDefaultsKey, as type: T.Type) -> T?
    func remove(forKey keys: any UserDefaultsKey...)
    func removeAll()
}

final class UserDefaultsManagerImpl: UserDefaultsManager {
    private let serializer: CodableSerializable
    private let userDefaults = UserDefaults.standard
    
    init(serializer: CodableSerializable = JSONSerializer()) {
        self.serializer = serializer
    }
    
    func save<T: Codable>(_ value: T, forKey key: any UserDefaultsKey) {
        if isPrimitiveType(T.self) {
            userDefaults.set(value, forKey: key.value)
            return
        }
        
        do {
            let data = try serializer.serialize(value)
            userDefaults.set(data, forKey: key.value)
        } catch {
            print("Failed to encode data for key \(key.value): \(error)")
        }
    }
    
    func load<T: Codable>(forKey key: any UserDefaultsKey, as type: T.Type) -> T? {
        if isPrimitiveType(T.self) {
            return userDefaults.object(forKey: key.value) as? T
        }
        
        guard let data = userDefaults.data(forKey: key.value) else {
            return nil
        }
        
        do {
            return try serializer.deserialize(type, from: data)
        } catch {
            print("Failed to decode data for key \(key.value): \(error)")
            return nil
        }
    }
    
    /// 특정 키 삭제
    func remove(forKey keys: any UserDefaultsKey...) {
        keys.forEach { self.userDefaults.removeObject(forKey: $0.value) }
    }
    
    /// 모든 데이터 삭제
    func removeAll() {
        userDefaults.dictionaryRepresentation().forEach { (key, _) in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    private func isPrimitiveType<T>(_ type: T.Type) -> Bool {
        return type is Int.Type || type is Double.Type || type is Float.Type || type is Bool.Type || type is String.Type
    }
}
