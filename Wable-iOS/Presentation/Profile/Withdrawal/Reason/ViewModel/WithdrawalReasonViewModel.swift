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
        let selectedReasons = CurrentValueSubject<Set<WithdrawalReason>, Never>([])
        
        input.load
            .flatMap { _ -> AnyPublisher<[WithdrawalReasonCellItem], Never>  in
                return .just(WithdrawalReason.allCases.map { WithdrawalReasonCellItem(reason: $0, isSelected: false) })
            }
            .sink { outputSubject.value.items = $0 }
            .store(in: cancelBag)
        
        input.checkbox
            .handleEvents(receiveOutput: { reason in
                if selectedReasons.value.contains(reason) {
                    selectedReasons.value.remove(reason)
                } else {
                    selectedReasons.value.insert(reason)
                }
            })
            .compactMap { reason in
                return outputSubject.value.items.firstIndex { $0.reason == reason }
            }
            .sink { outputSubject.value.items[$0].isSelected.toggle() }
            .store(in: cancelBag)
        
        selectedReasons
            .map { $0.isEmpty }
            .sink { outputSubject.value.isNextEnabled = !$0 }
            .store(in: cancelBag)
        
        input.next
            .map { Array(selectedReasons.value) }
            .sink { outputSubject.value.selectedReasons = $0 }
            .store(in: cancelBag)
        
        return outputSubject
            .removeDuplicates()
            .asDriver()
    }
}
