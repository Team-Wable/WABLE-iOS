//
//  ProfileEditViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import Combine
import Foundation
import UIKit

final class ProfileEditViewModel {

    // MARK: - Property

    private let userID: Int
    private var currentProfile: UserProfile?
    private var currentLckTeam: String = "LCK"
    private var currentProfileImageType: ProfileImageType?

    private let profileLoadedSubject = PassthroughSubject<UserProfile, Never>()
    private let nicknameValidationSubject = PassthroughSubject<NicknameValidationResult, Never>()
    private let nicknameDuplicationSuccessSubject = PassthroughSubject<Bool, Never>()
    private let profileUpdateCompletedSubject = PassthroughSubject<Void, Never>()

    @Injected private var profileRepository: ProfileRepository
    @Injected private var accountRepository: AccountRepository

    // MARK: - Life Cycle

    init(userID: Int) {
        self.userID = userID
    }
}

// MARK: - ViewModelType

extension ProfileEditViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let nicknameTextChanged: AnyPublisher<String, Never>
        let nicknameDuplicationCheckTrigger: AnyPublisher<String, Never>
        let lckTeamChanged: AnyPublisher<String, Never>
        let profileImageChanged: AnyPublisher<ProfileImageType, Never>
        let saveButtonTapped: AnyPublisher<String, Never>
    }

    struct Output {
        let profileLoaded: AnyPublisher<UserProfile, Never>
        let nicknameValidation: AnyPublisher<NicknameValidationResult, Never>
        let nicknameDuplicationResult: AnyPublisher<Bool, Never>
        let profileUpdateCompleted: AnyPublisher<Void, Never>
    }

    func transform(input: Input, cancelBag: CancelBag) -> Output {
        input.viewWillAppear
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.fetchProfile()
            }
            .sink { [weak self] profile in
                guard let self else { return }
                self.currentProfile = profile
                self.currentLckTeam = profile.user.fanTeam?.rawValue ?? "LCK"
                self.profileLoadedSubject.send(profile)
            }
            .store(in: cancelBag)

        input.nicknameTextChanged
            .map { [weak self] text in
                self?.validateNickname(text) ?? .empty
            }
            .sink { [weak self] result in
                self?.nicknameValidationSubject.send(result)
            }
            .store(in: cancelBag)

        input.nicknameDuplicationCheckTrigger
            .withUnretained(self)
            .flatMap { owner, nickname in
                owner.fetchNicknameDuplication(nickname)
            }
            .sink { [weak self] isValid in
                self?.nicknameDuplicationSuccessSubject.send(isValid)
            }
            .store(in: cancelBag)

        input.lckTeamChanged
            .sink { [weak self] team in
                self?.currentLckTeam = team
            }
            .store(in: cancelBag)

        input.profileImageChanged
            .sink { [weak self] imageType in
                self?.currentProfileImageType = imageType
            }
            .store(in: cancelBag)

        input.saveButtonTapped
            .withUnretained(self)
            .flatMap { owner, nickname in
                owner.updateProfile(nickname: nickname)
            }
            .sink { [weak self] in
                self?.profileUpdateCompletedSubject.send()
            }
            .store(in: cancelBag)

        return Output(
            profileLoaded: profileLoadedSubject.eraseToAnyPublisher(),
            nicknameValidation: nicknameValidationSubject.eraseToAnyPublisher(),
            nicknameDuplicationResult: nicknameDuplicationSuccessSubject.eraseToAnyPublisher(),
            profileUpdateCompleted: profileUpdateCompletedSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Private Helper Method

private extension ProfileEditViewModel {
    func fetchProfile() -> AnyPublisher<UserProfile, Never> {
        return profileRepository.fetchUserProfile(memberID: userID)
            .catch { error -> AnyPublisher<UserProfile, Never> in
                WableLogger.log("프로필 로드 중 에러 발생: \(error)", for: .error)
                return Empty().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func validateNickname(_ text: String) -> NicknameValidationResult {
        guard !text.isEmpty else { return .empty }
        guard let regex = try? NSRegularExpression(pattern: Constant.nicknamePattern) else { return .invalidFormat }

        let range = NSRange(location: 0, length: text.utf16.count)
        let isValid = regex.firstMatch(in: text, options: [], range: range) != nil

        return isValid ? .valid : .invalidFormat
    }

    func fetchNicknameDuplication(_ nickname: String) -> AnyPublisher<Bool, Never> {
        return accountRepository.fetchNicknameDuplication(nickname: nickname)
            .map { _ in true }
            .catch { _ -> AnyPublisher<Bool, Never> in return .just(false) }
            .eraseToAnyPublisher()
    }

    func updateProfile(nickname: String) -> AnyPublisher<Void, Never> {
        guard let profile = currentProfile else {
            return Empty().eraseToAnyPublisher()
        }

        let updatedProfile = UserProfile(
            user: User(
                id: profile.user.id,
                nickname: nickname,
                profileURL: profile.user.profileURL,
                fanTeam: LCKTeam(rawValue: currentLckTeam)
            ),
            introduction: profile.introduction,
            ghostCount: profile.ghostCount,
            lckYears: profile.lckYears,
            userLevel: profile.userLevel
        )

        let (image, defaultProfileType) = extractImageData(from: currentProfileImageType)

        return profileRepository.updateUserProfile(
            profile: updatedProfile,
            isPushAlarmAllowed: nil,
            isAlarmAllowed: nil,
            image: image,
            fcmToken: profileRepository.fetchFCMToken(),
            defaultProfileType: defaultProfileType
        )
        .catch { error -> AnyPublisher<Void, Never> in
            WableLogger.log("프로필 업데이트 중 에러 발생: \(error)", for: .error)
            return Empty().eraseToAnyPublisher()
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
            return (nil, nil)
        }
    }
}

// MARK: - Constant

private extension ProfileEditViewModel {
    enum Constant {
        static let nicknamePattern = "^[ㄱ-ㅎ가-힣a-zA-Z0-9]+$"
    }
}
