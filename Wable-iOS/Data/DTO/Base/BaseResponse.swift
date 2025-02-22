//
//  BaseResponse.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: T?
}
