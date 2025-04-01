//
//  WritePostViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/1/25.
//


import Combine
import Foundation

final class WritePostViewModel {
    private let createContentListUseCase: CreateContentUseCase
    
    init(createContentListUseCase: CreateContentUseCase) {
        self.createContentListUseCase = createContentListUseCase
    }
}

extension WritePostViewModel: ViewModelType {
    struct Input {
        let postButtonDidTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        
        return Output(
            
        )
    }
}

private extension WritePostViewModel {
    enum Constant {
        
    }
}

