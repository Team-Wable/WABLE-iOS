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
    }
    
    private let keychainStorage: KeychainStorage
    
    init(keyChainStorage: KeychainStorage) {
        self.keychainStorage = keyChainStorage
    }
}

extension TokenStorage {
    /// Saves the provided token in the keychain storage.
    ///
    /// The token is stored under a key generated from the token type's raw value. Throws an error if the storage operation fails.
    ///
    /// - Parameters:
    ///   - token: The token string to be saved.
    ///   - tokenType: The type of token, whose raw value is used as the key for storage.
    func save(_ token: String, for tokenType: TokenType) throws {
        try keychainStorage.setValue(token, for: tokenType.rawValue)
    }
    
    /// Loads a token from the keychain for the specified token type.
    ///
    /// Retrieves the token as raw data from keychain storage and converts it to a UTF-8 encoded string.
    /// Throws a TokenError.dataConversionFailed error if the token is missing or cannot be converted to a string.
    ///
    /// - Parameter tokenType: The type of token to load.
    /// - Returns: A UTF-8 encoded string representing the token.
    /// - Throws: TokenError.dataConversionFailed if token retrieval or decoding fails.
    func load(_ tokenType: TokenType) throws -> String {
        guard let token: Data = try keychainStorage.getValue(for: tokenType.rawValue),
              let tokenString = String(data: token, encoding: .utf8) else {
            throw TokenError.dataConversionFailed
        }
        
        return tokenString
    }
    
    /// Deletes the token associated with the specified token type from the keychain.
    ///
    /// This method attempts to remove the stored token for the provided token type. If the deletion fails, it throws an error.
    ///
    /// - Parameter tokenType: The token type whose corresponding token is to be deleted.
    /// - Throws: An error if the token cannot be removed from the keychain.
    func delete(_ tokenType: TokenType) throws {
        try keychainStorage.removeValue(for: tokenType.rawValue)
    }
}
