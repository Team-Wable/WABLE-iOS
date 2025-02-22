//
//  FetchInfoNotifications.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/16/25.
//

import Foundation

// MARK: - 정보 노티 조회

extension DTO.Response {
    struct FetchInfoNotifications: Decodable {
        let infoNotificationType, time, imageURL: String
        let infoNotificationID: Int

        enum CodingKeys: String, CodingKey {
            case infoNotificationID = "infoNotificationId"
            case infoNotificationType, time
            case imageURL = "imageUrl"
        }
    }
}

