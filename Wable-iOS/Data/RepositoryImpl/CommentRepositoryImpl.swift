//
//  CommentRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/19/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class CommentRepositoryImpl {
    private let provider = APIProvider<CommentTargetType>()
}

extension CommentRepositoryImpl: CommentRepository {
    func fetchUserCommentList(memberID: Int, cursor: Int) -> AnyPublisher<[CommentTemp], WableError> {
        return provider.request(
            .fetchUserCommentList(
                memberID: memberID,
                cursor: cursor
            ),
            for: [DTO.Response.FetchUserComments].self
        )
        .map(CommentMapper.toDomain)
        .mapWableError()
    }
    
    func fetchUserCommentList(memberID: Int, cursor: Int) async throws -> [CommentTemp] {
        do {
            let response = try await provider.request(
                .fetchUserCommentList(memberID: memberID, cursor: cursor),
                for: [DTO.Response.FetchUserComments].self
            )
            return CommentMapper.toDomain(response)
        } catch {
            throw ErrorMapper.map(error)
        }
    }
    
    func fetchContentCommentList(contentID: Int, cursor: Int) -> AnyPublisher<[CommentTemp], WableError> {
        return provider.request(
            .fetchContentCommentList(
                contentID: contentID,
                cursor: cursor
            ),
            for: [DTO.Response.FetchContentComments].self
        )
        .map { CommentMapper.toDomain(contentID, $0) }
        .mapWableError()
    }
    
    func deleteComment(commentID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .deleteComment(commentID: commentID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func deleteComment(commentID: Int) async throws {
        do {
            _ = try await provider.request(
                .deleteComment(commentID: commentID),
                for: DTO.Response.Empty.self
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }
    
    func createComment(contentID: Int, text: String, parentID: Int?, parentMemberID: Int?) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createComment(
                contentID: contentID,
                request: DTO.Request.CreateComment(
                    commentText: text,
                    parentCommentID: parentID ?? -1,
                    parentCommentWriterID: parentMemberID ?? -1
                )
            )
            , for: DTO.Response.Empty.self)
        .asVoid()
        .mapWableError()
    }
}

struct MockCommentRepository: CommentRepository {
    func fetchUserCommentList(memberID: Int, cursor: Int) -> AnyPublisher<[CommentTemp], WableError> {
        .fail(.unknownError)
    }
    
    func fetchUserCommentList(memberID: Int, cursor: Int) async throws -> [CommentTemp] {
        if cursor < .zero {
            return Array(Self.mockUserComments.prefix(10))
        }
        
        guard let index = Self.mockUserComments.firstIndex(where: { $0.id == cursor }) else {
            return []
        }
        let start = index + 1
        let end = min(start + 10, Self.mockUserComments.count)
        return Array(Self.mockUserComments[start..<end])
    }
    
    func fetchContentCommentList(contentID: Int, cursor: Int) -> AnyPublisher<[CommentTemp], WableError> {
        .fail(.unknownError)
    }
    
    func deleteComment(commentID: Int) -> AnyPublisher<Void, WableError> {
        .fail(.unknownError)
    }
    
    func deleteComment(commentID: Int) async throws {
        throw WableError.unknownError
    }
    
    func createComment(contentID: Int, text: String, parentID: Int?, parentMemberID: Int?) -> AnyPublisher<Void, WableError> {
        .fail(.unknownError)
    }
    
    static let mockUserComments: [CommentTemp] = {
        let mockContentID = -1
        let mockUser = User(
            id: 167,
            nickname: "MockUser",
            profileURL: URL(string: "https://fastly.picsum.photos/id/1010/30/30.jpg?hmac=X5ekkqmSMlhAupHWilf0AAhRhn2_j47ENiy_PH8aFGM"),
            fanTeam: .t1
        )
        
        let temp: [CommentTemp] = (1...52).map { number in
            CommentTemp(
                id: number,
                author: mockUser,
                text: "\(number)번째",
                contentID: mockContentID,
                isDeleted: nil,
                createdDate: .now,
                parentContentID: nil,
                children: [],
                likeCount: 0,
                isLiked: false,
                opacity: .init(value: 0),
                status: .normal
            )
        }
        return temp
    }()
}
