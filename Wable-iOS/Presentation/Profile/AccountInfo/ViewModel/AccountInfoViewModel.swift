//
//  AccountInfoViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import Foundation

final class AccountInfoViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
    }
    
    struct Output: Equatable {
        var items: [AccountInfoCellItem] = []
        var errorMessage: String?
    }
    
    let input = Input()
    
    func bind(with cancelBag: CancelBag) -> AnyPublisher<Output, Never> {
        let outputSubject = CurrentValueSubject<Output, Never>(Output())
        
//        input.load
//            .flatMap { _ in
//
//                // TODO: 유저 정보 조회
//
//            }
//            .sink { }
//            .store(in: cancelBag)
        
        return outputSubject
            .removeDuplicates()
            .asDriver()
    }
}
