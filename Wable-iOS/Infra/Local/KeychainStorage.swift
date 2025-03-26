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
        guard let stringValue = value as? String,
              let stringData = stringValue.data(using: .utf8) else {
            throw LocalError.saveFailed
        }
        
        WableLogger.log("키체인에 데이터 저장 완료: \(stringValue)", for: .debug)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.wable.Wable-iOS",
            kSecValueData as String: stringData
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
            kSecAttrAccount as String: key,  // key 값을 kSecAttrAccount에 사용해야 함
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.wable.Wable-iOS",
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
            WableLogger.log("\(data)", for: .debug)
            return data as? T
        }
        
        if T.self == String.self,
           let stringValue = String(data: data, encoding: .utf8) {
            WableLogger.log("\(stringValue)", for: .debug)
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
