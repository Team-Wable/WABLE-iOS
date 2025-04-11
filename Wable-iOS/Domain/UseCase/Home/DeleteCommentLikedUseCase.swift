//
//  DeleteCommentLikedUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/6/25.
//


import Combine
import Foundation

final class DeleteCommentLikedUseCase {
    private let repository: CommentLikedRepository
    
    init(repository: CommentLikedRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension DeleteCommentLikedUseCase {
    func execute(commentID: Int) -> AnyPublisher<Void, WableError> {
        return repository.deleteCommentLiked(commentID: commentID)
    }
}
