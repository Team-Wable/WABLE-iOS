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
        let checkbox: Driver<Void>
        let withdraw: Driver<Void>
    }
    
    struct Output {
        let isNextEnabled: Driver<Bool>
        let isWithdrawSuccess: Driver<Bool>
        let errorMessage: Driver<String>
    }
    
    private let selectedReasons: [WithdrawalReason]
    private let withdrawUseCase: WithdrawUseCase
    private let removeUserSessionUseCase: RemoveUserSessionUseCase
    
    init(
        selectedReasons: [WithdrawalReason],
        withdrawUseCase: WithdrawUseCase,
        removeUserSessionUseCase: RemoveUserSessionUseCase
    ) {
        self.selectedReasons = selectedReasons
        self.withdrawUseCase = withdrawUseCase
        self.removeUserSessionUseCase = removeUserSessionUseCase
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let isNextEnabledRelay = CurrentValueRelay<Bool>(false)
        let errorMessageRelay = PassthroughRelay<String>()
        
        input.checkbox
            .sink { _ in isNextEnabledRelay.value.toggle() }
            .store(in: cancelBag)
        
        let isWithdrawSuccess = input.withdraw
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.withdrawUseCase.execute(reasons: owner.selectedReasons)
                    .catch { error -> AnyPublisher<Bool, Never> in
                        errorMessageRelay.send(error.localizedDescription)
                        return .just(false)
                    }
                    .filter { $0 }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] isSuccess in
                guard isSuccess else { return }
                self?.removeUserSessionUseCase.removeUserSession()
            })
            .asDriver()
        
        return Output(
            isNextEnabled: isNextEnabledRelay.asDriver(),
            isWithdrawSuccess: isWithdrawSuccess,
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}
