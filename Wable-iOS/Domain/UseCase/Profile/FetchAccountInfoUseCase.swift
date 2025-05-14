//
//  FetchAccountInfoUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol FetchAccountInfoUseCase {
    func execute() -> AnyPublisher<AccountInfo?, WableError>
}

final class FetchAccountInfoUseCaseImpl: FetchAccountInfoUseCase {
    private let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<AccountInfo?, WableError> {
        return repository.fetchUserInfo()
            .map { $0 }
            .eraseToAnyPublisher()
    }
}
