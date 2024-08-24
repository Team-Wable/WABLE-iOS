//
//  BaseResponse.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: T?
}
