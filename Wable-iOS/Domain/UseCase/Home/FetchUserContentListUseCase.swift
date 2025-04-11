//
//  FetchUserContentListUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/31/25.
//


import Combine
import Foundation

final class FetchUserContentListUseCase {
    private let repository: ContentRepository
    
    init(repository: ContentRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchUserContentListUseCase {
    func execute(memberID: Int, cursor: Int) -> AnyPublisher<[UserContent], WableError> {
        return repository.fetchUserContentList(memberID: memberID, cursor: cursor)
    }
}
