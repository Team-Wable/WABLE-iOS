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
    @Injected private var repository: UserSessionRepository
    @Injected private var tokenStorage: TokenStorage

    func removeUserSession() {
        guard let userID = repository.fetchActiveUserID() else {
            return WableLogger.log("유저 아이디를 찾을 수 없음.", for: .debug)
        }

        do {
            try tokenStorage.delete(.wableAccessToken)
            try tokenStorage.delete(.wableRefreshToken)
        } catch {
            WableLogger.log("토큰 삭제 실패: \(error.localizedDescription)", for: .debug)
        }

        repository.updateActiveUserID(nil)
    }
}
