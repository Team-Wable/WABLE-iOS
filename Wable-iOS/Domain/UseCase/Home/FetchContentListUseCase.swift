//
//  FetchContentListUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/31/25.
//


import Combine

final class FetchContentListUseCase {
    private let repository: ContentRepository
    
    init(repository: ContentRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchContentListUseCase {
    func execute(cursor: Int) -> AnyPublisher<[ContentTemp], WableError> {
        return repository.fetchContentList(cursor: cursor)
    }
}
