//
//  KeychainStorage.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/5/25.
//


import Foundation
import Security

struct KeychainStorage { }

extension KeychainStorage: LocalKeyValueProvider {
    func setValue<T>(_ value: T, for key: String) throws where T : Decodable, T : Encodable {
        let data = try JSONEncoder().encode(String(data: value as! Data, encoding: .utf8))
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw LocalError.saveFailed
        }
    }
    
    func getValue<T>(for key: String) throws -> T? where T : Decodable, T : Encodable {
        var item: AnyObject?
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data
        else {
            WableLogger.log("키체인에서 데이터를 찾을 수 없음: \(key), 상태: \(status)", for: .error)
            throw LocalError.dataNotFound
        }
        
        if T.self == Data.self {
            return data as? T
        }
        
        if T.self == String.self, let stringValue = String(data: data, encoding: .utf8) {
            return stringValue as? T
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func removeValue(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess {
            throw LocalError.deleteFailed
        }
    }
}
