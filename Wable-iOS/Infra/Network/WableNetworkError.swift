//
//  WableNetworkError.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/13/25.
//

import Foundation

enum WableNetworkError: Error, CustomStringConvertible {
    case decodedError(Error)
    /// 400
    case badRequest(message: String)
    /// 401
    case unauthorized(message: String)
    /// 404
    case notFound(message: String)
    /// 500
    case internalServerError
    case missingData
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .decodedError(let error):
            "디코딩 과정에서 오류가 발생했습니다: \(error.localizedDescription)"
        case .badRequest(let message), .unauthorized(let message), .notFound(let message):
            "\(message)"
        case .internalServerError:
            "서버 내부 오류입니다."
        case .missingData:
            "데이터 필드가 nil 입니다."
        case .unknown(let error):
            "알 수 없는 오류입니다: \(error.localizedDescription)"
        }
    }
    
    var description: String {
        localizedDescription
    }
}
