//
//  FetchAccountInfo.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//


import Foundation

// MARK: - 계정 정보 조회

extension DTO.Response {
    struct FetchAccountInfo: Decodable {
        let memberID: Int
        let joinDate, showMemberID, socialPlatform, versionInformation: String
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case joinDate
            case showMemberID = "showMemberId"
            case socialPlatform, versionInformation
        }
    }
}
