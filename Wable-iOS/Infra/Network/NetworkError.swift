//
//  NetworkError.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/13/25.
//

import Foundation

enum NetworkError: Error {
    case decodedError(Error)
    case statusError(code: Int, message: String)
    case internalServerError
    case missingData
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .decodedError(let error):
            "디코딩 과정에서 오류가 발생했습니다: \(error.localizedDescription)"
        case .statusError(let code, let message):
            "에러 코드 \(code): \(message)"
        case .internalServerError:
            "서버 내부 오류입니다."
        case .missingData:
            "데이터 필드가 nil 입니다."
        case .unknown(let error):
            "알 수 없는 오류입니다: \(error.localizedDescription)"
        }
    }
}
