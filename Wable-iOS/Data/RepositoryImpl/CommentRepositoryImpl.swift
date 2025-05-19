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
    func fetchUserCommentList(memberID: Int, cursor: Int) -> AnyPublisher<[UserComment], WableError> {
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
    
    func fetchUserCommentList(memberID: Int, cursor: Int) async throws -> [UserComment] {
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
    
    func fetchContentCommentList(contentID: Int, cursor: Int) -> AnyPublisher<[ContentComment], WableError> {
        return provider.request(
            .fetchContentCommentList(
                contentID: contentID,
                cursor: cursor
            ),
            for: [DTO.Response.FetchContentComments].self
        )
        .map(CommentMapper.toDomain)
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
