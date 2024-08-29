//
//  WriteReplyRequestDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/30/24.
//

import Foundation
import UIKit

struct WriteReplyRequestDTO: Encodable {
    let commentText: String
    let notificationTriggerType: String
}
