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
    let memberID: Int
    let triggerType: TriggerType
    let triggerID: Int
}
