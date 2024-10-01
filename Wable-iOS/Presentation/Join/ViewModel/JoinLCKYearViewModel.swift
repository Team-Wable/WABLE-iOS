//
//  JoinLCKYearViewModel.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import Combine
import Foundation

final class JoinLCKYearViewModel: ViewModelType {
    
    private let cancelBag = CancelBag()
    
    private let pushOrPopViewController = PassthroughSubject<Int, Never>()
    
    struct Input {
        let backButtonTapped: AnyPublisher<Void, Never>
        let nextButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let pushOrPopViewController: PassthroughSubject<Int, Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.backButtonTapped
            .sink { _ in
                self.pushOrPopViewController.send(0)
            }
            .store(in: cancelBag)
        
        input.nextButtonTapped
            .sink { _ in
                AmplitudeManager.shared.trackEvent(tag: "click_next_year_signup")
                self.pushOrPopViewController.send(1)
            }
            .store(in: cancelBag)
        
        return Output(pushOrPopViewController: pushOrPopViewController)
    }
}
