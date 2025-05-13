//
//  AlarmSettingViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/13/25.
//

import Combine
import Foundation
import UserNotifications

final class AlarmSettingViewModel {
    struct Input {
        let checkAlarmAuthorization = PassthroughSubject<Void, Never>()
    }
    
    struct Output: Equatable {
        var isAuthorized: Bool = false
    }
    
    let input = Input()
    
    func bind(with cancelBag: CancelBag) -> AnyPublisher<Output, Never> {
        let outputSubject = CurrentValueSubject<Output, Never>(Output())
        
        input.checkAlarmAuthorization
            .flatMap { _ -> AnyPublisher<Bool, Never> in
                return Future<Bool, Never> { promise in
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        promise(.success(settings.authorizationStatus == .authorized))
                    }
                }
                .eraseToAnyPublisher()
            }
            .sink { outputSubject.value.isAuthorized = $0 }
            .store(in: cancelBag)
        
        return outputSubject
            .removeDuplicates()
            .asDriver()
    }
 }

// MARK: - Async/Await를 사용했을 때 뷰모델

//final class AlarmSettingViewModel {
//    @Published private(set) var isAuthorized: Bool = false
//
//    func checkAlarmAuthorization() {
//        Task {
//            let settings = await UNUserNotificationCenter.current().notificationSettings()
//            isAuthorized = settings.authorizationStatus == .authorized
//        }
//    }
//}
