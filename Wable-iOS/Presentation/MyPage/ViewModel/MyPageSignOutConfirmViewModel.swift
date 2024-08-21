//
//  MyPageSignOutConfirmViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/21/24.
//

import Combine
import Foundation

final class MyPageSignOutConfirmViewModel: ViewModelType {
    private let cancelBag = CancelBag()
//    private let networkProvider: NetworkServiceType
    
    private let pushOrPopViewController = PassthroughSubject<Int, Never>()
    private let isEnabled = PassthroughSubject<Bool, Never>()
    
    private var checkBoxChecked = false
    
    struct Input {
        let backButtonTapped: AnyPublisher<Void, Never>
        let checkButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let pushOrPopViewController: PassthroughSubject<Int, Never>
        let isEnable: PassthroughSubject<Bool, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.backButtonTapped
            .sink { _ in
                self.pushOrPopViewController.send(0)
            }
            .store(in: cancelBag)
        
        input.checkButtonTapped
            .sink { [weak self] _ in
                self?.checkBoxChecked.toggle()
                self?.isEnabled.send(self?.checkBoxChecked ?? false)
            }
            .store(in: cancelBag)
        
        return Output(pushOrPopViewController: pushOrPopViewController,
                      isEnable: isEnabled)
    }
    
//    init(networkProvider: NetworkServiceType) {
//        self.networkProvider = networkProvider
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
