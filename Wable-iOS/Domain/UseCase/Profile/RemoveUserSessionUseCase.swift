//
//  RemoveUserSessionUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Foundation

protocol RemoveUserSessionUseCase {
    func removeUserSession(for nickname: String)
}

final class RemoveUserSessionUseCaseImpl: RemoveUserSessionUseCase {
    private let cancelBag: CancelBag
    
    @Injected private var profileRepository: ProfileRepository
    @Injected private var repository: UserSessionRepository
    @Injected private var tokenStorage: TokenStorage

    init(cancelBag: CancelBag = CancelBag()) {
        self.cancelBag = cancelBag
    }

    func removeUserSession(for nickname: String) {
        profileRepository.clearFCMToken(for: nickname)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        WableLogger.log("FCM 토큰 제거 실패: \(error)", for: .error)
                    } else {
                        WableLogger.log("FCM 토큰 제거 성공", for: .debug)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: cancelBag)
        
        do {
            try tokenStorage.delete(.wableAccessToken)
            try tokenStorage.delete(.wableRefreshToken)
        } catch {
            WableLogger.log("토큰 삭제 실패: \(error.localizedDescription)", for: .error)
        }

        repository.updateActiveUserID(nil)
    }
}
