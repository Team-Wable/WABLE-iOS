//
//  TokenStorage.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/16/25.
//


import Foundation

struct TokenStorage {
    enum TokenType: String {
        case loginAccessToken = "loginAccessToken"
        case wableAccessToken = "accessToken"
        case wableRefreshToken = "refreshToken"
        case fcmToken = "fcmToken"
    }
    
    private let keychainStorage: KeychainStorage
    
    init(keyChainStorage: KeychainStorage) {
        self.keychainStorage = keyChainStorage
    }
}

extension TokenStorage {
    func save(_ token: String, for tokenType: TokenType) throws {
        try keychainStorage.setValue(token, for: tokenType.rawValue)
    }
    
    func load(_ tokenType: TokenType) throws -> String {
        guard let token: Data = try keychainStorage.getValue(for: tokenType.rawValue),
              let tokenString = String(data: token, encoding: .utf8) else {
            throw TokenError.dataConversionFailed
        }
        
        return tokenString
    }
    
    func delete(_ tokenType: TokenType) throws {
        try keychainStorage.removeValue(for: tokenType.rawValue)
    }
}
