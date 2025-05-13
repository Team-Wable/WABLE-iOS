//
//  WithdrawalReasonViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

final class WithdrawalReasonViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let checkbox = PassthroughSubject<WithdrawalReason, Never>()
        let next = PassthroughSubject<Void, Never>()
    }
    
    struct Output: Equatable {
        var items: [WithdrawalReasonCellItem] = []
        var isNextEnabled: Bool = false
        var selectedReasons: [WithdrawalReason] = []
    }
    
    let input = Input()
    
    func bind(with cancelBag: CancelBag) -> AnyPublisher<Output, Never> {
        let outputSubject = CurrentValueSubject<Output, Never>(Output())
        
        input.load
            .flatMap { _ -> AnyPublisher<[WithdrawalReasonCellItem], Never>  in
                return .just(WithdrawalReason.allCases.map { WithdrawalReasonCellItem(reason: $0, isSelected: false) })
            }
            .sink { outputSubject.value.items = $0 }
            .store(in: cancelBag)
        
        input.checkbox
            .compactMap { reason in
                return outputSubject.value.items.firstIndex { $0.reason == reason }
            }
            .sink { outputSubject.value.items[$0].isSelected.toggle() }
            .store(in: cancelBag)
        
        input.next
            .map { outputSubject.value.items.compactMap { $0.isSelected ? $0.reason : nil } }
            .sink { outputSubject.value.selectedReasons = $0 }
            .store(in: cancelBag)
        
        return outputSubject
            .removeDuplicates()
            .asDriver()
    }
}
