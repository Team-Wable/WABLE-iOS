//
//  TokenStorage.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/16/25.
//


import Foundation

enum TokenStorage {
    
    // MARK: - TokenType

    enum TokenType: String {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
    }
    
    static func save(_ token: String, for tokenType: TokenType) throws {
        guard let data = token.data(using: .utf8) else {
            throw TokenStorageError.dataConversionFailed
        }
        
        try KeychainWrapper.save(data, for: tokenType.rawValue)
    }
    
    static func load(_ tokenType: TokenType) throws -> String {
        let data = try KeychainWrapper.load(for: tokenType.rawValue)
        
        guard let token = String(data: data, encoding: .utf8) else {
            throw TokenStorageError.dataConversionFailed
        }
        
        return token
    }
    
    static func delete(_ tokenType: TokenType) throws {
        try KeychainWrapper.delete(for: tokenType.rawValue)
    }
}

// MARK: - TokenStorageError

extension TokenStorage {
    enum TokenStorageError: Error {
        case dataConversionFailed
    }
}
