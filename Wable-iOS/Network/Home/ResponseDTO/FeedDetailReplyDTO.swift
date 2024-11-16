//
//  FeedDetailReplyDTO.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/19/24.
//

// MARK: - 게시글에 대한 댓글 리스트 조회

struct FeedDetailReplyDTO: Codable {
    let commentId: Int
    let memberId: Int
    let memberProfileUrl: String
    let memberNickname: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let commentLikedNumber: Int
    let commentText: String
    let time: String
    let isDeleted: Bool
    let commentImageUrl: String?
    let memberFanTeam: String
}

// MARK: - 1.1.0v DTO

struct FeedReplyListDTO: Codable {
    let commentID, memberID: Int
    let memberProfileURL, memberNickname: String
    let isGhost: Bool
    let memberGhost: Int
    let isLiked: Bool
    let commentLikedNumber: Int
    let commentText, time: String
    let isDeleted: Bool
    let memberFanTeam: String
    let parentCommentID: Int // 현재 답글이 대댓글일 경우, 어떤 댓글에 대한 대댓글인지(-1이 아니라면 레이아웃 변경 - 대댓글 더 안쪽으로)
    let isBlind: Bool?
    
    enum CodingKeys: String, CodingKey {
        case commentID = "commentId"
        case memberID = "memberId"
        case memberProfileURL = "memberProfileUrl"
        case memberNickname, isGhost, memberGhost, isLiked, commentLikedNumber, commentText, time, isDeleted, memberFanTeam
        case parentCommentID = "parentCommentId"
        case isBlind
    }
}

extension FeedReplyListDTO {
    
    static var dummyData: [FeedReplyListDTO] = [FeedReplyListDTO(commentID: 200,
                                                                 memberID: 81,
                                                                 memberProfileURL: "PURPLE",
                                                                 memberNickname: "하잉잉",
                                                                 isGhost: false,
                                                                 memberGhost: 0,
                                                                 isLiked: false,
                                                                 commentLikedNumber: 0,
                                                                 commentText: "테스트입니당당당",
                                                                 time: "2024-02-06 23:46:50",
                                                                 isDeleted: false,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: -1,
                                                                 isBlind: false),
                                                FeedReplyListDTO(commentID: 201,
                                                                 memberID: 81,
                                                                 memberProfileURL: "PURPLE",
                                                                 memberNickname: "우하하",
                                                                 isGhost: false,
                                                                 memberGhost: 0,
                                                                 isLiked: false,
                                                                 commentLikedNumber: 0,
                                                                 commentText: "냥냥",
                                                                 time: "2024-02-06 23:46:50",
                                                                 isDeleted: false,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: 200,
                                                                 isBlind: false),
                                                FeedReplyListDTO(commentID: 202,
                                                                 memberID: 81,
                                                                 memberProfileURL: "PURPLE",
                                                                 memberNickname: "앙냥냥냥",
                                                                 isGhost: false,
                                                                 memberGhost: 0,
                                                                 isLiked: false,
                                                                 commentLikedNumber: 0,
                                                                 commentText: "함나읾;ㄴ앎니ㅏㄹㅇ",
                                                                 time: "2024-02-06 23:46:50",
                                                                 isDeleted: false,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: 200,
                                                                 isBlind: false),
                                                FeedReplyListDTO(commentID: 203,
                                                                 memberID: 81,
                                                                 memberProfileURL: "PURPLE",
                                                                 memberNickname: "농농농농",
                                                                 isGhost: false,
                                                                 memberGhost: 0,
                                                                 isLiked: false,
                                                                 commentLikedNumber: 0,
                                                                 commentText: "ㅁㄴ얾닝라ㅓ민ㅇ러ㅏㅗ머낭뢈어",
                                                                 time: "2024-02-06 23:46:50",
                                                                 isDeleted: false,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: 200,
                                                                 isBlind: false),
                                                FeedReplyListDTO(commentID: 204,
                                                                 memberID: 81,
                                                                 memberProfileURL: "PURPLE",
                                                                 memberNickname: "기차낭",
                                                                 isGhost: false,
                                                                 memberGhost: 0,
                                                                 isLiked: false,
                                                                 commentLikedNumber: 0,
                                                                 commentText: "이건 댓글입니당",
                                                                 time: "2024-02-06 23:46:50",
                                                                 isDeleted: false,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: -1,
                                                                 isBlind: false),
                                                FeedReplyListDTO(commentID: 205,
                                                                 memberID: 81,
                                                                 memberProfileURL: "PURPLE",
                                                                 memberNickname: "더미데이터기차나",
                                                                 isGhost: false,
                                                                 memberGhost: 0,
                                                                 isLiked: false,
                                                                 commentLikedNumber: 0,
                                                                 commentText: "요건 대댓글입니당",
                                                                 time: "2024-02-06 23:46:50",
                                                                 isDeleted: false,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: -1,
                                                                 isBlind: false),
                                                FeedReplyListDTO(commentID: 206,
                                                                 memberID: 81,
                                                                 memberProfileURL: "PURPLE",
                                                                 memberNickname: "자고싶어",
                                                                 isGhost: false,
                                                                 memberGhost: 0,
                                                                 isLiked: false,
                                                                 commentLikedNumber: 0,
                                                                 commentText: "대대대대대대대대대대대대댓글",
                                                                 time: "2024-02-06 23:46:50",
                                                                 isDeleted: false,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: 205,
                                                                 isBlind: false)]
    
}
