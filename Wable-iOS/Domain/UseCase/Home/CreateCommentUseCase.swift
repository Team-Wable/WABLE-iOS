//
//  CreateCommentUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/6/25.
//


import Combine
import Foundation

final class CreateCommentUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension CreateCommentUseCase {
    func execute(contentID: Int, text: String, parentID: Int?, parentMemberID: Int?) -> AnyPublisher<Void, WableError> {
        return repository.createComment(
            contentID: contentID,
            text: text,
            parentID: parentID,
            parentMemberID: parentMemberID
        )
    }
}
