//
//  CreateContentLikedUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/2/25.
//


import Combine
import Foundation

final class CreateContentLikedUseCase {
    private let repository: ContentLikedRepository
    
    init(repository: ContentLikedRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension CreateContentLikedUseCase {
    func execute(contentID: Int) -> AnyPublisher<Void, WableError> {
        return repository.createContentLiked(contentID: contentID, triggerType: "contentLiked")
    }
}

