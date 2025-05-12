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
    }
    
    struct Output {
        let items: Driver<[AccountInfoCellItem]>
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
        
        return Output(
            items: .just([]),
            errorMessage: errorMessageRelay.asDriver()
        )
    }
}
