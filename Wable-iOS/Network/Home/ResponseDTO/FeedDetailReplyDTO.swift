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
    let commentImageURL: String?
    let memberFanTeam: String
    let parentCommentID: Int // 현재 답글이 대댓글일 경우, 어떤 댓글에 대한 대댓글인지(-1이 아니라면 레이아웃 변경 - 대댓글 더 안쪽으로)
    let isBlind: Bool?
    var childComments: [FeedReplyListDTO]?
    
    enum CodingKeys: String, CodingKey {
        case commentID = "commentId"
        case memberID = "memberId"
        case memberProfileURL = "memberProfileUrl"
        case memberNickname, isGhost, memberGhost, isLiked, commentLikedNumber, commentText, time, isDeleted, memberFanTeam
        case commentImageURL = "commentImageUrl"
        case parentCommentID = "parentCommentId"
        case isBlind
        case childComments
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
                                                                 commentImageURL: nil,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: -1,
                                                                 isBlind: false,
                                                                 childComments: [FeedReplyListDTO(commentID: 300,
                                                                                                  memberID: 81,
                                                                                                  memberProfileURL: "BLUE",
                                                                                                  memberNickname: "대댓글1",
                                                                                                  isGhost: false,
                                                                                                  memberGhost: 0,
                                                                                                  isLiked: false,
                                                                                                  commentLikedNumber: 0,
                                                                                                  commentText: "냐ㅑ냐ㅑ냐냐냐ㅑ냐ㅑ냐냐",
                                                                                                  time: "2024-02-06 23:46:50",
                                                                                                  isDeleted: false,
                                                                                                  commentImageURL: nil,
                                                                                                  memberFanTeam: "DK",
                                                                                                  parentCommentID: 200,
                                                                                                  isBlind: false,
                                                                                                  childComments: nil),
                                                                                 FeedReplyListDTO(commentID: 300,
                                                                                                  memberID: 81,
                                                                                                  memberProfileURL: "BLUE",
                                                                                                  memberNickname: "대댓글2",
                                                                                                  isGhost: false,
                                                                                                  memberGhost: 0,
                                                                                                  isLiked: false,
                                                                                                  commentLikedNumber: 0,
                                                                                                  commentText: "냐ㅑ냐ㅑ냐냐냐ㅑ냐ㅑ냐냐",
                                                                                                  time: "2024-02-06 23:46:50",
                                                                                                  isDeleted: false,
                                                                                                  commentImageURL: nil,
                                                                                                  memberFanTeam: "DK",
                                                                                                  parentCommentID: 200,
                                                                                                  isBlind: false,
                                                                                                  childComments: nil),
                                                                                 FeedReplyListDTO(commentID: 300,
                                                                                                  memberID: 81,
                                                                                                  memberProfileURL: "BLUE",
                                                                                                  memberNickname: "대댓글3",
                                                                                                  isGhost: false,
                                                                                                  memberGhost: 0,
                                                                                                  isLiked: false,
                                                                                                  commentLikedNumber: 0,
                                                                                                  commentText: "냐ㅑ냐ㅑ냐냐냐ㅑ냐ㅑ냐냐",
                                                                                                  time: "2024-02-06 23:46:50",
                                                                                                  isDeleted: false,
                                                                                                  commentImageURL: nil,
                                                                                                  memberFanTeam: "DK",
                                                                                                  parentCommentID: 200,
                                                                                                  isBlind: false,
                                                                                                  childComments: nil),
                                                                                 FeedReplyListDTO(commentID: 300,
                                                                                                  memberID: 81,
                                                                                                  memberProfileURL: "BLUE",
                                                                                                  memberNickname: "대댓글4",
                                                                                                  isGhost: false,
                                                                                                  memberGhost: 0,
                                                                                                  isLiked: false,
                                                                                                  commentLikedNumber: 0,
                                                                                                  commentText: "냐ㅑ냐ㅑ냐냐냐ㅑ냐ㅑ냐냐",
                                                                                                  time: "2024-02-06 23:46:50",
                                                                                                  isDeleted: false,
                                                                                                  commentImageURL: nil,
                                                                                                  memberFanTeam: "DK",
                                                                                                  parentCommentID: 200,
                                                                                                  isBlind: false,
                                                                                                  childComments: nil)]),
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
                                                                 commentImageURL: nil,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: -1,
                                                                 isBlind: false,
                                                                 childComments: [FeedReplyListDTO(commentID: 300,
                                                                                                  memberID: 81,
                                                                                                  memberProfileURL: "BLUE",
                                                                                                  memberNickname: "대댓글5",
                                                                                                  isGhost: false,
                                                                                                  memberGhost: 0,
                                                                                                  isLiked: false,
                                                                                                  commentLikedNumber: 0,
                                                                                                  commentText: "냐ㅑ냐ㅑ냐냐냐ㅑ냐ㅑ냐냐",
                                                                                                  time: "2024-02-06 23:46:50",
                                                                                                  isDeleted: false,
                                                                                                  commentImageURL: nil,
                                                                                                  memberFanTeam: "DK",
                                                                                                  parentCommentID: 201,
                                                                                                  isBlind: false,
                                                                                                  childComments: nil),
                                                                                 FeedReplyListDTO(commentID: 300,
                                                                                                  memberID: 81,
                                                                                                  memberProfileURL: "BLUE",
                                                                                                  memberNickname: "대댓글6",
                                                                                                  isGhost: false,
                                                                                                  memberGhost: 0,
                                                                                                  isLiked: false,
                                                                                                  commentLikedNumber: 0,
                                                                                                  commentText: "냐ㅑ냐ㅑ냐냐냐ㅑ냐ㅑ냐냐",
                                                                                                  time: "2024-02-06 23:46:50",
                                                                                                  isDeleted: false,
                                                                                                  commentImageURL: nil,
                                                                                                  memberFanTeam: "DK",
                                                                                                  parentCommentID: 201,
                                                                                                  isBlind: false,
                                                                                                  childComments: nil)]),
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
                                                                 commentImageURL: nil,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: -1,
                                                                 isBlind: false,
                                                                 childComments: [FeedReplyListDTO(commentID: 300,
                                                                                                  memberID: 81,
                                                                                                  memberProfileURL: "BLUE",
                                                                                                  memberNickname: "대댓글7",
                                                                                                  isGhost: false,
                                                                                                  memberGhost: 0,
                                                                                                  isLiked: false,
                                                                                                  commentLikedNumber: 0,
                                                                                                  commentText: "냐ㅑ냐ㅑ냐냐냐ㅑ냐ㅑ냐냐",
                                                                                                  time: "2024-02-06 23:46:50",
                                                                                                  isDeleted: false,
                                                                                                  commentImageURL: nil,
                                                                                                  memberFanTeam: "DK",
                                                                                                  parentCommentID: 202,
                                                                                                  isBlind: false,
                                                                                                  childComments: nil),
                                                                                 FeedReplyListDTO(commentID: 300,
                                                                                                  memberID: 81,
                                                                                                  memberProfileURL: "BLUE",
                                                                                                  memberNickname: "대댓글8",
                                                                                                  isGhost: false,
                                                                                                  memberGhost: 0,
                                                                                                  isLiked: false,
                                                                                                  commentLikedNumber: 0,
                                                                                                  commentText: "냐ㅑ냐ㅑ냐냐냐ㅑ냐ㅑ냐냐",
                                                                                                  time: "2024-02-06 23:46:50",
                                                                                                  isDeleted: false,
                                                                                                  commentImageURL: nil,
                                                                                                  memberFanTeam: "DK",
                                                                                                  parentCommentID: 202,
                                                                                                  isBlind: false,
                                                                                                  childComments: nil)]),
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
                                                                 commentImageURL: nil,
                                                                 memberFanTeam: "T1",
                                                                 parentCommentID: -1,
                                                                 isBlind: false,
                                                                 childComments: nil)
                                                ]
}

extension FeedReplyListDTO {
    // FeedReplyListDTO를 FlattenReplyListDTO로 변환하는 메서드
    func toFlattenReplyListDTO() -> FlattenReplyModel {
        return FlattenReplyModel(
            commentID: self.commentID,
            memberID: self.memberID,
            memberProfileURL: self.memberProfileURL,
            memberNickname: self.memberNickname,
            isGhost: self.isGhost,
            memberGhost: self.memberGhost,
            isLiked: self.isLiked,
            commentLikedNumber: self.commentLikedNumber,
            commentText: self.commentText,
            time: self.time,
            isDeleted: self.isDeleted,
            memberFanTeam: self.memberFanTeam,
            parentCommentID: self.parentCommentID,
            isBlind: self.isBlind
        )
    }
}

extension Array where Element == FeedReplyListDTO {
    // FeedReplyListDTO 배열을 FlattenReplyListDTO 배열로 평탄화 및 매핑하는 메서드
    func toFlattenedReplyList() -> [FlattenReplyModel] {
        var flattenedList: [FlattenReplyModel] = []

        func flatten(_ feedReplies: [FeedReplyListDTO]) {
            for reply in feedReplies {
                // 현재 댓글을 FlattenReplyListDTO로 변환 후 추가
                flattenedList.append(reply.toFlattenReplyListDTO())

                // childComments가 있으면 재귀적으로 평탄화
                if let childComments = reply.childComments {
                    flatten(childComments)
                }
            }
        }

        // 시작 배열 평탄화 호출
        flatten(self)
        return flattenedList
    }
}
