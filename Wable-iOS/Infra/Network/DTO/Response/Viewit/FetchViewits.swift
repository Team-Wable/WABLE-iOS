//
//  FetchViewits.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/20/25.
//


import Foundation

// MARK: - 뷰잇 목록 조회

extension DTO.Response {
    struct FetchViewits: Decodable {
        let memberID: Int
        let memberProfileURL: String
        let memberNickname: String
        let viewitID: Int
        let viewitImageURL: String?
        let viewitURL: String?
        let viewitTitle: String
        let viewitText: String
        let viewitName: String?
        let time: String
        let isLiked: Bool
        let likedNumber: Int
        let isBlind: Bool
        
        enum CodingKeys: String, CodingKey {
            case memberID = "memberId"
            case memberProfileURL = "memberProfileUrl"
            case memberNickname
            case viewitID = "viewitId"
            case viewitImageURL = "viewitImage"
            case viewitURL = "viewitLink"
            case viewitTitle, viewitText, viewitName, time, isLiked, likedNumber, isBlind
        }
    }
}
