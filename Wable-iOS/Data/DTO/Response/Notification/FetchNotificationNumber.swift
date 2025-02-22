//
//  FetchNotificationNumber.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/16/25.
//


import Foundation

// MARK: - 확인하지 않은 노티 개수

extension DTO.Response {
    struct FetchNotificationNumber: Decodable {
        let notificationNumber: Int
    }
}
