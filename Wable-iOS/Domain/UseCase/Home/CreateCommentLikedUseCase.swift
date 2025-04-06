//
//  CreateCommentLikedUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/6/25.
//


import Combine
import Foundation

final class CreateCommentLikedUseCase {
    private let repository: CommentLikedRepository
    
    init(repository: CommentLikedRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension CreateCommentLikedUseCase {
    func execute(commentID: Int, notificationText: String) -> AnyPublisher<Void, WableError> {
        return repository.createCommentLiked(
            commentID: commentID,
            triggerType: "commentLiked",
            notificationText: notificationText
        )
    }
}
