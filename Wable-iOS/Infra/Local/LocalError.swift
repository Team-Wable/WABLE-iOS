//
//  LocalError.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/5/25.
//


import Foundation

enum LocalError: Error {
    case saveFailed
    case dataNotFound
    case deleteFailed
    
    var localizedDescription: String {
        switch self {
        case .saveFailed:
            return "💿 저장에 실패했습니다."
        case .dataNotFound:
            return "🧭 항목을 찾을 수 없습니다."
        case .deleteFailed:
            return "🧹 삭제에 실패했습니다."
        }
    }
}
