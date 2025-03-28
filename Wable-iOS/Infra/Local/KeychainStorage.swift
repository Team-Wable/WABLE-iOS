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
    /// Stores a string value in the Keychain under the specified key.
    ///
    /// The function attempts to interpret the provided value as a String and encode it using UTF-8.
    /// It deletes any existing entry for the key before adding the new value.
    /// If the value cannot be converted to a String or if the underlying Keychain operation fails,
    /// the function throws a `LocalError.saveFailed` error.
    ///
    /// - Parameters:
    ///   - value: The value to store, which must be convertible to a String.
    ///   - key: The key under which the value is saved in the Keychain.
    ///
    /// - Throws: `LocalError.saveFailed` if conversion to String/Data fails or if the Keychain operation is unsuccessful.
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
    
    /// Retrieves a value from the Keychain for the provided key.
    ///
    /// The function builds a query to retrieve data associated with the specified key using the app’s bundle identifier as the service. It then returns the value as the expected type:
    /// - If T is `Data`, the raw data is returned.
    /// - If T is `String`, the data is converted from UTF-8 encoding.
    /// - Otherwise, the data is decoded from JSON using `JSONDecoder`.
    ///
    /// - Parameter key: The key under which the value is stored.
    /// - Returns: The value decoded to type T if retrieval and conversion succeed.
    /// - Throws: 
    ///   - `LocalError.dataNotFound` if the Keychain item is missing or retrieval fails.
    ///   - A decoding error if the value cannot be converted to type T.
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
    
    /// Removes the value associated with the specified key from the Keychain.
    /// 
    /// Constructs a query using the provided key and attempts to delete the corresponding Keychain item.
    /// If the deletion operation fails, it throws a `LocalError.deleteFailed` error.
    /// 
    /// - Parameter key: A string representing the key for which the value should be removed.
    /// - Throws: `LocalError.deleteFailed` if the deletion is unsuccessful.
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
