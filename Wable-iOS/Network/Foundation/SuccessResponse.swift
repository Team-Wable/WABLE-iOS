//
//  GenericResponse.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import Foundation

struct SuccessResponse<T: Codable>: Codable {
    let status: Int?
    let success: Bool?
    let message: String?
    let data: T?
}
