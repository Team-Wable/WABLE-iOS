//
//  AgreementViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import Combine
import Foundation
import UIKit

final class AgreementViewModel {

    // MARK: - Property

    private let profileInfo: OnboardingProfileInfo
    private let registrationCompletedSubject = PassthroughSubject<Void, Never>()

    @Injected private var profileRepository: ProfileRepository
    @Injected private var userSessionRepository: UserSessionRepository

    // MARK: - Life Cycle

    init(profileInfo: OnboardingProfileInfo) {
        self.profileInfo = profileInfo
    }
}

// MARK: - ViewModelType

extension AgreementViewModel: ViewModelType {
    struct Input {
        let completeButtonTapped: AnyPublisher<Bool, Never>
    }

    struct Output {
        let registrationCompleted: AnyPublisher<Void, Never>
    }

    func transform(input: Input, cancelBag: CancelBag) -> Output {
        input.completeButtonTapped
            .withUnretained(self)
            .flatMap { owner, isMarketingAgreed in
                owner.completeRegistration(isMarketingAgreed: isMarketingAgreed)
            }
            .sink { [weak self] in
                self?.registrationCompletedSubject.send()
            }
            .store(in: cancelBag)

        return Output(
            registrationCompleted: registrationCompletedSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

extension AgreementViewModel {
    func getWelcomeMessage() -> String {
        return "\(profileInfo.nickname ?? "")님\n와블의 일원이 되신 것을 환영해요.\nLCK 함께 보며 같이 즐겨요 :)"
    }
}

// MARK: - Private Helper Method

private extension AgreementViewModel {
    func completeRegistration(isMarketingAgreed: Bool) -> AnyPublisher<Void, Never> {
        return userSessionRepository.fetchActiveUserSession()
            .publisher
            .compactMap { $0 }
            .withUnretained(self)
            .flatMap { owner, userSession in
                owner.updateProfile(userSession: userSession, isMarketingAgreed: isMarketingAgreed)
            }
            .eraseToAnyPublisher()
    }

    func updateProfile(userSession: UserSession, isMarketingAgreed: Bool) -> AnyPublisher<Void, Never> {
        let profile = UserProfile(
            user: User(
                id: userSession.id,
                nickname: profileInfo.nickname ?? "",
                profileURL: userSession.profileURL,
                fanTeam: LCKTeam(rawValue: profileInfo.lckTeam ?? "LCK")
            ),
            introduction: "",
            ghostCount: 0,
            lckYears: profileInfo.lckYear ?? 0,
            userLevel: 1
        )

        let (image, defaultProfileType) = extractImageData(from: profileInfo.profileImageType)

        return profileRepository.updateUserProfile(
            profile: profile,
            isPushAlarmAllowed: isMarketingAgreed,
            isAlarmAllowed: isMarketingAgreed,
            image: image,
            fcmToken: profileRepository.fetchFCMToken(),
            defaultProfileType: defaultProfileType
        )
        .flatMap { [weak self] _ in
            self?.updateFCMToken() ?? Empty().eraseToAnyPublisher()
        }
        .handleEvents(receiveOutput: { [weak self] _ in
            guard let self else { return }

            userSessionRepository.updateUserSession(
                userID: userSession.id,
                nickname: self.profileInfo.nickname ?? userSession.nickname,
                profileURL: userSession.profileURL,
                isPushAlarmAllowed: isMarketingAgreed,
                isAdmin: userSession.isAdmin,
                isAutoLoginEnabled: true,
                notificationBadgeCount: userSession.notificationBadgeCount ?? 0,
                quizCompletedAt: nil
            )

            WableLogger.log("세션 저장 완료", for: .debug)
        })
        .catch { error -> AnyPublisher<Void, Never> in
            WableLogger.log("프로필 업데이트 중 에러 발생: \(error)", for: .error)
            return Empty().eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func updateFCMToken() -> AnyPublisher<Void, Never> {
        guard let token = profileRepository.fetchFCMToken() else {
            WableLogger.log("FCM 토큰 없음", for: .error)
            return .just(())
        }

        return profileRepository.updateUserProfile(nickname: profileInfo.nickname ?? "", fcmToken: token)
            .catch { error -> AnyPublisher<Void, Never> in
                WableLogger.log("FCM 토큰 저장 중 에러 발생: \(error)", for: .error)
                return .just(())
            }
            .eraseToAnyPublisher()
    }
    
    func extractImageData(from profileImageType: ProfileImageType?) -> (image: UIImage?, defaultProfileType: String?) {
        switch profileImageType {
        case .custom(let image):
            return (image, nil)
        case .default(let type):
            return (nil, type.uppercased)
        case .none:
            return (nil, DefaultProfileType.random().uppercased)
        }
    }
}
