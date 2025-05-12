//
//  AccountInfoViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import Foundation

final class AccountInfoViewModel {
    
}

extension AccountInfoViewModel: ViewModelType {
    struct Input {
        let load: Driver<Void>
        let withdraw: Driver<Void>
    }
    
    struct Output {
        let items: Driver<[AccountInfoCellItem]>
        let isWithdrawSuccess: Driver<Bool>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        let errorMessageRelay = PassthroughRelay<String>()
        
//        let items = input.load
//            .flatMap { _ in
//                
//                // TODO: 유저 정보 조회
//                
//            }
//            .asDriver()
        
//        let isWithdrawSuccess = input.withdrawl
//            .flatMap { _ in
//                
//                // TODO: 계정 삭제
//                
//            }
//            .asDriver()
        
        return Output(
            items: .just([]),
            isWithdrawSuccess: .just(false),
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}
