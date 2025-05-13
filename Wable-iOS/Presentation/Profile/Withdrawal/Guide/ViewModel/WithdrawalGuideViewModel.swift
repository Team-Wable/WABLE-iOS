//
//  WithdrawalGuideViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

final class WithdrawalGuideViewModel {
    struct Input {
        let checkbox = PassthroughSubject<Void, Never>()
        let withdraw = PassthroughSubject<Void, Never>()
    }
    
    struct Output: Equatable {
        var isNextEnabled = false
        var isWithdrawSuccess = false
        var errorMessage: String?
    }
    
    let input = Input()
    
    private let selectedReasons: [WithdrawalReason]
    
    init(selectedReasons: [WithdrawalReason]) {
        self.selectedReasons = selectedReasons
    }
    
    func bind(with cancelBag: CancelBag) -> AnyPublisher<Output, Never> {
        let output = CurrentValueSubject<Output, Never>(Output())
        
        input.checkbox
            .sink { _ in output.value.isNextEnabled.toggle() }
            .store(in: cancelBag)
        
        input.withdraw
//            .flatMap { _ in
//                
//                // TODO: 탈퇴 과정 실행
//                
//            }
            .sink { _ in
                output.value.isWithdrawSuccess = true
            }
            .store(in: cancelBag)
        
        return output
            .removeDuplicates()
            .asDriver()
    }
}
