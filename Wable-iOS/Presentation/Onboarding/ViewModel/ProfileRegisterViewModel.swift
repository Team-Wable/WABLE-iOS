//
//  ProfileRegisterViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import Combine
import Foundation

final class ProfileRegisterViewModel {

    // MARK: - Property

    private let profileInfo: OnboardingProfileInfo
    private let nicknameDuplicationSuccessSubject = PassthroughSubject<Bool, Never>()
    private let nicknameValidationSubject = PassthroughSubject<NicknameValidationResult, Never>()

    @Injected private var accountRepository: AccountRepository

    // MARK: - Life Cycle

    init(profileInfo: OnboardingProfileInfo) {
        self.profileInfo = profileInfo
    }
}

// MARK: - ViewModelType

extension ProfileRegisterViewModel: ViewModelType {
    struct Input {
        let nicknameTextChanged: AnyPublisher<String, Never>
        let nicknameDuplicationCheckTrigger: AnyPublisher<String, Never>
    }

    struct Output {
        let nicknameValidation: AnyPublisher<NicknameValidationResult, Never>
        let nicknameDuplicationResult: AnyPublisher<Bool, Never>
    }

    func transform(input: Input, cancelBag: CancelBag) -> Output {
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

        return Output(
            nicknameValidation: nicknameValidationSubject.eraseToAnyPublisher(),
            nicknameDuplicationResult: nicknameDuplicationSuccessSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

extension ProfileRegisterViewModel {
    func getProfileInfo(nickname: String, profileImageType: ProfileImageType?) -> OnboardingProfileInfo {
        var updatedProfileInfo = profileInfo
        updatedProfileInfo.nickname = nickname
        updatedProfileInfo.profileImageType = profileImageType

        return updatedProfileInfo
    }
}

private extension ProfileRegisterViewModel {
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
}

// MARK: - Constant

private extension ProfileRegisterViewModel {
    enum Constant {
        static let nicknamePattern = "^[ㄱ-ㅎ가-힣a-zA-Z0-9]+$"
    }
}
