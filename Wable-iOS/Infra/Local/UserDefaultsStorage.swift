//
//  UserDefaultsStorage.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/4/25.
//


import Foundation

struct UserDefaultsStorage {
    private let userDefaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    init(userDefaults: UserDefaults, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.userDefaults = userDefaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
}

extension UserDefaultsStorage: LocalStorage {
    func setValue<T>(_ value: T, for key: String) throws where T : Decodable, T : Encodable {
        guard let data = try? jsonEncoder.encode(value) else {
            throw LocalError.saveFailed
        }
        
        userDefaults.set(data, forKey: key)
    }
    
    func getValue<T>(for key: String) throws -> T? where T : Decodable, T : Encodable {
        guard let data = userDefaults.data(forKey: key) else {
            throw LocalError.dataNotFound
        }
        
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    func removeValue(for key: String) throws {
        guard userDefaults.object(forKey: key) != nil else {
            throw LocalError.dataNotFound
        }
        
        userDefaults.removeObject(forKey: key)
    }
}
