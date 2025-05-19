//
//  FetchAccountInfoUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol FetchAccountInfoUseCase {
    func execute() async throws -> AccountInfo
}

final class FetchAccountInfoUseCaseImpl: FetchAccountInfoUseCase {
    private let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> AccountInfo {
        return try await repository.fetchAccountInfo()
    }
}
