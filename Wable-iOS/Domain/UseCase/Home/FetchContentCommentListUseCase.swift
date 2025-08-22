//
//  FetchContentCommentListUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/6/25.
//


import Combine
import Foundation

final class FetchContentCommentListUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchContentCommentListUseCase {
    func execute(contentID: Int, cursor: Int) -> AnyPublisher<[CommentTemp], WableError> {
        return repository.fetchContentCommentList(contentID: contentID, cursor: cursor)
    }
}
