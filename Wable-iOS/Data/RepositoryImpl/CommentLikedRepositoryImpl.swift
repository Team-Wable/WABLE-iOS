//
//  CommentLikedRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/19/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class CommentLikedRepositoryImpl {
    private let provider = APIProvider<CommentLikedTargetType>()
}

extension CommentLikedRepositoryImpl: CommentLikedRepository {
    func createCommentLiked(commentID: Int, triggerType: String, notificationText: String) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createCommentLiked(
                commentID: commentID,
                request: DTO.Request.CreateCommentLiked(
                    notificationTriggerType: triggerType,
                    notificationText: notificationText
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func createCommentLiked(commentID: Int, triggerType: String, notificationText: String) async throws {
        do {
            _ = try await provider.request(
                .createCommentLiked(
                    commentID: commentID,
                    request: DTO.Request.CreateCommentLiked(
                        notificationTriggerType: triggerType,
                        notificationText: notificationText
                    )
                ),
                for: DTO.Response.Empty.self
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }
    
    func deleteCommentLiked(commentID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .deleteCommentLiked(commentID: commentID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func deleteCommentLiked(commentID: Int) async throws {
        do {
            _ = try await provider.request(
                .deleteCommentLiked(commentID: commentID),
                for: DTO.Response.Empty.self
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }
}
