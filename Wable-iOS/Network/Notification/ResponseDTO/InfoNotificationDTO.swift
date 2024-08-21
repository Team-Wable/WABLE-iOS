//
//  NotificationDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/21/24.
//

import UIKit

struct InfoNotificationDTO: Codable {
    let infoNotificationType, time, imageURL: String

    enum CodingKeys: String, CodingKey {
        case infoNotificationType, time
        case imageURL = "imageUrl"
    }
}
