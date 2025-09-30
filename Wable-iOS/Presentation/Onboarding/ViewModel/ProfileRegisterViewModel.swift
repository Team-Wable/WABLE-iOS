//
//  ProfileRegisterViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import Combine
import Foundation

// MARK: - Enum

extension ProfileRegisterViewModel {
    enum ValidationResult {
        case empty
        case valid
        case invalidFormat
    }
}

final class ProfileRegisterViewModel {

    // MARK: - Property

    private let lckYear: Int
    private let lckTeam: String
    private let nicknameDuplicationSuccessSubject = PassthroughSubject<Bool, Never>()
    private let nicknameValidationSubject = PassthroughSubject<ValidationResult, Never>()

    @Injected private var accountRepository: AccountRepository

    // MARK: - Life Cycle

    init(lckYear: Int, lckTeam: String) {
        self.lckYear = lckYear
        self.lckTeam = lckTeam
    }
}

// MARK: - ViewModelType

extension ProfileRegisterViewModel: ViewModelType {
    struct Input {
        let nicknameTextChanged: AnyPublisher<String, Never>
        let nicknameDuplicationCheckTrigger: AnyPublisher<String, Never>
    }

    struct Output {
        let nicknameValidation: AnyPublisher<ValidationResult, Never>
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
                owner.checkNicknameDuplication(nickname)
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
    func getRegistrationData(nickname: String) -> (nickname: String, lckYear: Int, lckTeam: String) {
        return (nickname, lckYear, lckTeam)
    }
}

private extension ProfileRegisterViewModel {
    func validateNickname(_ text: String) -> ValidationResult {
        guard !text.isEmpty else { return .empty }
        guard let regex = try? NSRegularExpression(pattern: Constant.nicknamePattern) else { return .invalidFormat }

        let range = NSRange(location: 0, length: text.utf16.count)
        let isValid = regex.firstMatch(in: text, options: [], range: range) != nil

        return isValid ? .valid : .invalidFormat
    }

    func checkNicknameDuplication(_ nickname: String) -> AnyPublisher<Bool, Never> {
        let useCase = FetchNicknameDuplicationUseCase(repository: accountRepository)

        return useCase.execute(nickname: nickname)
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
