//
//  WithdrawalGuideViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

final class WithdrawalGuideViewModel: ViewModelType {
    struct Input {
        let checkbox: AnyPublisher<Void, Never>
        let withdraw: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let isNextEnabled: AnyPublisher<Bool, Never>
        let isWithdrawSuccess: AnyPublisher<Void, Never>
        let errorMessage: AnyPublisher<String, Never>
    }
    
    private let selectedReasons: [WithdrawalReason]
    private let withdrawUseCase: WithdrawUseCase
    private let errorMessageSubject = PassthroughSubject<String, Never>()
    
    init(
        selectedReasons: [WithdrawalReason],
        withdrawUseCase: WithdrawUseCase,
    ) {
        self.selectedReasons = selectedReasons
        self.withdrawUseCase = withdrawUseCase
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let isNextEnabledSubject = CurrentValueSubject<Bool, Never>(false)
        
        input.checkbox
            .sink { _ in isNextEnabledSubject.value.toggle() }
            .store(in: cancelBag)
        
        let isWithdrawSuccess = input.withdraw
            .withUnretained(self)
            .flatMap { owner, _ -> AnyPublisher<Void, Never> in
                return owner.withdraw()
            }
            .asDriver()
        
        let errorMessage = errorMessageSubject
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .asDriver()
        
        return Output(
            isNextEnabled: isNextEnabledSubject.asDriver(),
            isWithdrawSuccess: isWithdrawSuccess,
            errorMessage: errorMessage
        )
    }
}

// MARK: - Helper Method

private extension WithdrawalGuideViewModel {
    func withdraw() -> AnyPublisher<Void, Never> {
        return withdrawUseCase.execute(reasons: selectedReasons)
            .catch { [weak self] error -> AnyPublisher<Void, Never> in
                WableLogger.log("회원 탈퇴 실패: \(error.localizedDescription)", for: .error)
                self?.errorMessageSubject.send(error.localizedDescription)
                return .empty()
            }
            .eraseToAnyPublisher()
    }
}
