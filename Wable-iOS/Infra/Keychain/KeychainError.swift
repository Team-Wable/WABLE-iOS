//
//  KeychainError.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/15/25.
//


import Foundation

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case dataNotFound(OSStatus)
    case deleteFailed(OSStatus)
    
    var localizedDescription: String {
        switch self {
        case .saveFailed(let status):
            return "Keychain 저장에 실패했습니다. (OSStatus: \(status))"
        case .dataNotFound(let status):
            return "Keychain에서 항목을 찾을 수 없습니다. (OSStatus: \(status))"
        case .deleteFailed(let status):
            return "Keychain 삭제에 실패했습니다. (OSStatus: \(status))"
        }
    }
}
