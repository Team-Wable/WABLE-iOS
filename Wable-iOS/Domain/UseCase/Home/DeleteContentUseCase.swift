//
//  DeleteContentUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/31/25.
//


import Combine
import Foundation

final class DeleteContentUseCase {
    private let repository: ContentRepository
    
    init(repository: ContentRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension DeleteContentUseCase {
    func execute(contentID: Int) -> AnyPublisher<Void, WableError> {
        return repository.deleteContent(contentID: contentID)
    }
}
