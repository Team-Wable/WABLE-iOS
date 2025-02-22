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
    func createCommentLiked(commentID: Int, triggerType: String, notificationText: String) -> AnyPublisher<Void, any Error> {
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
        .asVoidWithError()
    }
    
    func deleteCommentLiked(commentID: Int) -> AnyPublisher<Void, any Error> {
        return provider.request(
            .deleteCommentLiked(commentID: commentID),
            for: DTO.Response.Empty.self
        )
        .asVoidWithError()
    }
}
