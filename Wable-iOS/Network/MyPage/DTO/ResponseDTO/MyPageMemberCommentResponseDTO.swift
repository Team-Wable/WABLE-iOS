//
//  MyPageMemberCommentResponseDTO.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/24/24.
//

import Foundation

// MARK: - MyPageMemberCommentResponseDTO

struct MyPageMemberCommentResponseDTO: Decodable {
    let memberId: Int
    let memberProfileUrl: String
    let memberNickname: String
    let isLiked: Bool
    let isGhost: Bool
    let memberGhost: Int
    let commentLikedNumber: Int
    let commentText: String
    let time: String
    let commentId: Int
    let contentId: Int
    let commentImageUrl: String?
    let memberFanTeam: String
}
