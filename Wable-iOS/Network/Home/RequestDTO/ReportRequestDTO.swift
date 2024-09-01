//
//  ReportRequestDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 9/1/24.
//

import Foundation

// MARK: - ReportRequestDTO

struct ReportRequestDTO: Encodable {
    let reportTargetNickname: String
    let relateText: String
}
