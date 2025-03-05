//
//  TokenStorage.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/16/25.
//


import Foundation

struct TokenStorage {
    
    // MARK: - TokenType

    enum TokenType: String {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
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
            throw TokenStorageError.dataConversionFailed
        }
        
        return token
    }
    
    func delete(_ tokenType: TokenType) throws {
        try keychainStorage.removeValue(for: tokenType.rawValue)
    }
}

// MARK: - TokenStorageError

extension TokenStorage {
    enum TokenStorageError: Error {
        case dataConversionFailed
    }
}
