//
//  PostTransparencyRequestDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 9/1/24.
//

import Foundation

// MARK: - PostTransparencyRequestDTO

struct PostTransparencyRequestDTO: Encodable {
    let alarmTriggerType: String
    let targetMemberId: Int
    let alarmTriggerId: Int
    let ghostReason: String
}
