//
//  ProfileRegisterViewModel.swift
//  Wable-iOS
//
//  Created by YOUJIM on 7/7/25.
//


import Combine
import Foundation

final class ProfileRegisterViewModel {
    
    // MARK: - Property
    
    private let isNicknameDuplicated = PassthroughSubject<Bool, Never>()
    
    @Injected private var accountRepository: AccountRepository
}

extension ProfileRegisterViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        return Output()
    }
}

// MARK: - Extension

