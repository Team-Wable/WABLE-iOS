//
//  NotificationPageViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 1/13/25.
//

import Foundation
import Combine

final class NotificationPageViewModel {
    
}

extension NotificationPageViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let currentIndex: AnyPublisher<Int, Never>
    }
    
    struct Output {
        
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        input.currentIndex
            .compactMap { index -> String? in
                switch index {
                case 0:
                    return "click_activitiesnoti"
                case 1:
                    return "click_infonoti"
                default:
                    return nil
                }
            }
            .sink { AmplitudeManager.shared.trackEvent(tag: $0) }
            .store(in: cancelBag)
        
        return Output()
    }
}
