//
//  SimpleResponse.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import Foundation

struct ErrorResponse: Codable {
    let status: Int?
    let success: Bool?
    let message: String?
}
