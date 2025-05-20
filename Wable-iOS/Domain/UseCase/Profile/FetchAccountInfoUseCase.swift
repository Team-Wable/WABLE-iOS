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
    @Injected private var repository: ProfileRepository
    
    func execute() async throws -> AccountInfo {
        return try await repository.fetchAccountInfo()
    }
}
