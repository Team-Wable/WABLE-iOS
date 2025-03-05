//
//  FetchNicknameDuplicationUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

final class FetchNicknameDuplicationUseCase {
    private let repository: AccountRepository
    
    init(repository: AccountRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchNicknameDuplicationUseCase {
    func execute(nickname: String) -> AnyPublisher<Void, WableError> {
        return repository.fetchNicknameDuplication(nickname: nickname)
            .eraseToAnyPublisher()
    }
}
