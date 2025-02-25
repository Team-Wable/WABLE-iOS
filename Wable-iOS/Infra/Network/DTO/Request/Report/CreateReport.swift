//
//  CreateReport.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/20/25.
//


import Foundation

// MARK: - 신고하기 버튼

extension DTO.Request {
    struct CreateReport: Encodable {
        let reportTargetNickname: String
        let relateText: String
    }
}
