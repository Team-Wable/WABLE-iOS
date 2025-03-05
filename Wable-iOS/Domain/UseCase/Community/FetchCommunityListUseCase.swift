//
//  FetchCommunityListUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

final class FetchCommunityListUseCase {
    private let repository: CommunityRepository
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchCommunityListUseCase {
    func execute() -> AnyPublisher<[Community], WableError> {
        return repository.fetchCommunityList()
            .eraseToAnyPublisher()
    }
}
