//
//  BanRequestDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 11/29/24.
//

import Foundation

struct BanRequestDTO: Encodable {
    let memberID: Int
    let triggerType: String
    let triggerID: Int
    
    enum CodingKeys: String, CodingKey {
        case memberID = "memberId"
        case triggerType
        case triggerID = "triggerId"
    }
}
