//
//  BanTargetInfo.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 12/17/24.
//

import Foundation

enum TriggerType: String {
    case comment = "comment"
    case content = "content"
}

struct BanTargetInfo {
    var memberID: Int
    var triggerType: TriggerType
    var triggerID: Int
}
