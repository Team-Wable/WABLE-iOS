//
//  AppDelegate+Firebase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/28/25.
//

import UIKit

import FirebaseCore
import FirebaseMessaging

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().token() { [weak self] token, error in
            guard let self = self else { return }
            
            self.saveFCMToken(token: token)
        }
    }
}

// MARK: - Helper Method

extension AppDelegate {
    func configureFirebase(application: UIApplication) {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
    }
    
    private func saveFCMToken(token: String?) {
        profileRepository.updateUserProfile(fcmToken: token)
            .sink { completion in
                if case .failure(let error) = completion {
                    WableLogger.log("FCMToken 업데이트 중 오류 발생: \(error)", for: .error)
                }
            } receiveValue: { _ in
            }
            .store(in: cancelBag)
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        saveFCMToken(token: fcmToken)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let aps = response.notification.request.content.userInfo["aps"] as? [String: Any],
              let badge = aps["badge"] as? Int
        else {
            return
        }
        
        userBadgeUseCase.execute(number: badge - 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    WableLogger.log("뱃지 수정 중 오류 발생: \(error)", for: .error)
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                
                self.userSessionRepository.updateNotificationBadge(count: badge, forUserID: activeID)
            }
            .store(in: cancelBag)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
