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
    func fetchUserCommentList(memberID: Int, cursor: Int) -> AnyPublisher<[UserComment], any Error> {
        return provider.request(
            .fetchUserCommentList(
                memberID: memberID,
                cursor: cursor
            ),
            for: [DTO.Response.FetchUserComments].self
        )
        .map { comments in
            CommentMapper.userCommentMapper(comments)
        }
        .normalizeError()
    }
    
    func fetchContentCommentList(contentID: Int, cursor: Int) -> AnyPublisher<[ContentComment], any Error> {
        return provider.request(
            .fetchContentCommentList(
                contentID: contentID,
                cursor: cursor
            ),
            for: [DTO.Response.FetchContentComments].self
        )
        .map { contents in
            CommentMapper.contentCommentMapper(contents)
        }
        .normalizeError()
    }
    
    func deleteComment(commentID: Int) -> AnyPublisher<Void, any Error> {
        return provider.request(
            .deleteComment(commentID: commentID),
            for: DTO.Response.Empty.self
        )
        .asVoidWithError()
    }
    
    func createComment(contentID: Int, text: String, parentID: Int?, parentMemberID: Int?) -> AnyPublisher<Void, any Error> {
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
        .asVoidWithError()
    }
}
