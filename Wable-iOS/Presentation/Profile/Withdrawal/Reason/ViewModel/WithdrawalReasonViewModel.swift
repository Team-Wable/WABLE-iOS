//
//  WithdrawalReasonViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

struct WithdrawalReasonViewModel: ViewModelType {
    struct Input {
        let load: Driver<Void>
        let checkbox: Driver<WithdrawalReason>
        let next: Driver<Void>
    }
    
    struct Output {
        let items: Driver<[WithdrawalReasonCellItem]>
        let isNextEnabled: Driver<Bool>
        let selectedReasons: Driver<[WithdrawalReason]>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let itemsRelay = CurrentValueRelay<[WithdrawalReasonCellItem]>([])
        let selectedReasonsRelay = CurrentValueRelay<Set<WithdrawalReason>>([])
        let isNextEnabledRelay = CurrentValueRelay<Bool>(false)
        
        input.load
            .flatMap { _ -> AnyPublisher<[WithdrawalReasonCellItem], Never>  in
                return .just(WithdrawalReason.allCases.map { WithdrawalReasonCellItem(reason: $0, isSelected: false) })
            }
            .sink { itemsRelay.send($0) }
            .store(in: cancelBag)
        
        input.checkbox
            .sink { reason in
                guard let index = itemsRelay.value.firstIndex(where: { $0.reason == reason }) else { return }
                
                var item = itemsRelay.value[index]
                item.isSelected.toggle()
                itemsRelay.value[index] = item
                
                if item.isSelected {
                    selectedReasonsRelay.value.insert(reason)
                } else {
                    selectedReasonsRelay.value.remove(reason)
                }
            }
            .store(in: cancelBag)
        
        selectedReasonsRelay
            .map { !$0.isEmpty }
            .sink { isNextEnabledRelay.send($0) }
            .store(in: cancelBag)
            
        let selectedReasons = input.next
            .map { Array(selectedReasonsRelay.value) }
            .asDriver()
        
        return Output(
            items: itemsRelay.asDriver(),
            isNextEnabled: isNextEnabledRelay.asDriver(),
            selectedReasons: selectedReasons
        )
    }
}
