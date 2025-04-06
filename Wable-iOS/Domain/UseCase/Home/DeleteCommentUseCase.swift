//
//  DeleteCommentUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/6/25.
//


import Combine
import Foundation

final class DeleteCommentUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension DeleteCommentUseCase {
    func execute(commentID: Int) -> AnyPublisher<Void, WableError> {
        return repository.deleteComment(commentID: commentID)
    }
}
