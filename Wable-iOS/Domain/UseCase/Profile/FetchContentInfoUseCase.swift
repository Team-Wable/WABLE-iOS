//
//  FetchContentInfoUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/31/25.
//


import Combine

final class FetchContentInfoUseCase {
    private let repository: ContentRepository
    
    init(repository: ContentRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchContentInfoUseCase {
    func execute(contentID: Int, title: String) -> AnyPublisher<ContentInfo, WableError> {
        return repository.fetchContentInfo(contentID: contentID, title: title)
    }
}
