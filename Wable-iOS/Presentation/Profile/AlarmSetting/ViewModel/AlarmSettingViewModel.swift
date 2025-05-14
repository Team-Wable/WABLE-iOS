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
    @Published private(set) var isAuthorized: Bool = false

    func checkAlarmAuthorization() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
}
