//
//  RemoveUserSessionUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Foundation

protocol RemoveUserSessionUseCase {
    func removeUserSession()
}

final class RemoveUserSessionUseCaseImpl: RemoveUserSessionUseCase {
    private let repository: UserSessionRepository
    private let tokenStorage: TokenStorage

    init(
        repository: UserSessionRepository = UserSessionRepositoryImpl(userDefaults: UserDefaultsStorage()),
        tokenStorage: TokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    ) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }

    func removeUserSession() {
        do {
            try tokenStorage.delete(.wableAccessToken)
            try tokenStorage.delete(.wableRefreshToken)
        } catch {
            WableLogger.log("토큰 삭제 실패: \(error.localizedDescription)", for: .error)
        }

        repository.updateActiveUserID(nil)
    }
}
