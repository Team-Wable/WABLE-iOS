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
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge],
            completionHandler: { _, _ in }
        )
    }
    
    private func saveFCMToken(token: String?) {
        guard let token = token else { return }
        
        self.profileRepository.updateFCMToken(token: token)
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
                
                self.userSessionRepository.updateUserSession(userID: activeID, notificationBadgeCount: badge)
                WableLogger.log("뱃지 수정 완료: \(badge)개", for: .debug)
            }
            .store(in: cancelBag)
        
        guard let relateContentID = response.notification.request.content.userInfo["relateContentId"] as? String,
              let contentID = Int(relateContentID),
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            return
        }
        
        let detailViewController = HomeDetailViewController(
            viewModel: HomeDetailViewModel(
                contentID: contentID,
                fetchContentInfoUseCase: FetchContentInfoUseCase(repository: contentRepository),
                fetchContentCommentListUseCase: FetchContentCommentListUseCase(repository: commentRepository),
                createCommentUseCase: CreateCommentUseCase(repository: commentRepository),
                deleteCommentUseCase: DeleteCommentUseCase(repository: commentRepository),
                createContentLikedUseCase: CreateContentLikedUseCase(repository: contentLikedRepository),
                deleteContentLikedUseCase: DeleteContentLikedUseCase(repository: contentLikedRepository),
                createCommentLikedUseCase: CreateCommentLikedUseCase(repository: commentLikedRepository),
                deleteCommentLikedUseCase: DeleteCommentLikedUseCase(repository: commentLikedRepository),
                fetchUserInformationUseCase: FetchUserInformationUseCase(repository: userSessionRepository),
                fetchGhostUseCase: FetchGhostUseCase(repository: GhostRepositoryImpl()),
                createReportUseCase: CreateReportUseCase(repository: reportRepository),
                createBannedUseCase: CreateBannedUseCase(repository: reportRepository),
                deleteContentUseCase: DeleteContentUseCase(repository: contentRepository)
            ),
            cancelBag: CancelBag()
        )
        
        if let tabBarController = rootViewController as? TabBarController {
            guard let viewController = tabBarController.selectedViewController as? UINavigationController else { return }
            
            tabBarController.selectedIndex = 0
            viewController.pushViewController(detailViewController, animated: true)
        } else
        if let viewController = rootViewController as? UINavigationController {
            viewController.pushViewController(detailViewController, animated: true)
        }
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
