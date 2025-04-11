//
//  DeleteContentLikedUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/2/25.
//


import Combine
import Foundation

final class DeleteContentLikedUseCase {
    private let repository: ContentLikedRepository
    
    init(repository: ContentLikedRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension DeleteContentLikedUseCase {
    func execute(contentID: Int) -> AnyPublisher<Void, WableError> {
        return repository.deleteContentLiked(contentID: contentID)
    }
}
