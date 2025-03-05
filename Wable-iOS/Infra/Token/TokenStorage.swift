//
//  TokenStorage.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/16/25.
//


import Foundation

struct TokenStorage {
    enum TokenType: String {
        case kakaoAccessToken = "kakaoAccessToken"
        case wableAccessToken = "accessToken"
        case wableRefreshToken = "refreshToken"
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
        guard let token: String = try keychainStorage.getValue(for: tokenType.rawValue) else {
            throw TokenError.dataConversionFailed
        }
        
        return token
    }
    
    func delete(_ tokenType: TokenType) throws {
        try keychainStorage.removeValue(for: tokenType.rawValue)
    }
}
