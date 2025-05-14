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
    
    init(selectedReasons: [WithdrawalReason]) {
        self.selectedReasons = selectedReasons
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let isNextEnabledRelay = CurrentValueRelay<Bool>(false)
        let isWithdrawSuccess = CurrentValueRelay<Bool>(false)
        let errorMessageRelay = PassthroughRelay<String>()
        
        input.checkbox
            .sink { _ in isNextEnabledRelay.value.toggle() }
            .store(in: cancelBag)
        
        return Output(
            isNextEnabled: isNextEnabledRelay.asDriver(),
            isWithdrawSuccess: isWithdrawSuccess.asDriver(),
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}
