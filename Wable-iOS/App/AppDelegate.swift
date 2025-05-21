//
//  AppDelegate.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//

import UIKit

import FirebaseCore
import FirebaseMessaging
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Property
    // TODO: Repository를 UseCase로 변경
    
    let userBadgeUseCase = UpdateUserBadgeUseCase(repository: AccountRepositoryImpl())
    let userSessionRepository = UserSessionRepositoryImpl(userDefaults: UserDefaultsStorage(jsonEncoder: JSONEncoder(), jsonDecoder: JSONDecoder()))
    let profileRepository = ProfileRepositoryImpl()
    let contentRepository = ContentRepositoryImpl()
    let commentRepository = CommentRepositoryImpl()
    let contentLikedRepository = ContentLikedRepositoryImpl()
    let commentLikedRepository = CommentLikedRepositoryImpl()
    let reportRepository = ReportRepositoryImpl()
    let cancelBag = CancelBag()
    
    var activeID = -1
    
    // MARK: - didFinishLaunchingWithOptions
    /// 앱 실행 후 초기화 시 호출
    /// Firebase 초기화 & 알람 관련 delegate 설정 및 알람 권한 요청 (Alert 표시)
    ///

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        injectDependency()
        fetchActiveID()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { [weak self] granted, error in
                guard let self = self,
                      let activeSession = userSessionRepository.fetchActiveUserSession() else { return
                }
                
                self.userSessionRepository.updateUserSession(userID: activeSession.id, isPushAlarmAllowed: granted)
            }
        )

        
        application.registerForRemoteNotifications()
        
        KakaoSDK.initSDK(appKey: Bundle.kakaoAppKey)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - didRegisterForRemoteNotificationsWithDeviceToken
    /// APNs 토큰을 먼저 발급받고, 그 토큰을 FCM SDK로 전달하는 메서드

    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      Messaging.messaging().apnsToken = deviceToken
      print("APNs token retrieved: \(deviceToken)")
      let deviceTokenString = deviceToken.map{ String(format: "%02x", $0) }.joined()
      print(deviceTokenString)
    }
    
    // MARK: - didFailToRegisterForRemoteNotificationsWithError
    /// 앱이 APNs 등록에 실패하거나, Remote Notification을 위한 구성에 실패한 경우 호출되는 에러 핸들러

    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - didReceiveRemoteNotification
    /// Silent Push 수신 시 호출

    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable : Any],
      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
      print("🟠", #function)
      completionHandler(.newData)
    }

}

// MARK: - MessagingDelegate
/// 정상적으로 FCM 토큰이 발급되면 호출되는 메서드

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        self.profileRepository.updateFCMToken(token: fcmToken)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      didReceive response: UNNotificationResponse
    ) async {
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
                
                self.userSessionRepository.updateUserSession(userID: activeID, notificationBadgeCount: badge - 1)
                WableLogger.log("뱃지 수정 완료: \(badge - 1)개", for: .debug)
                UIApplication.shared.applicationIconBadgeNumber = badge - 1
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
            
            WableLogger.log("상세 화면으로 이동 완료", for: .debug)
        } else
        if let viewController = rootViewController as? UINavigationController {
            viewController.pushViewController(detailViewController, animated: true)
            
            WableLogger.log("상세 화면으로 이동 완료", for: .debug)
        }
    }
    
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
      print("🟢", #function)
      return [.sound, .banner, .badge]
    }
}

// MARK: - Helper Method

private extension AppDelegate {
    func fetchActiveID() {
        guard let id = self.userSessionRepository.fetchActiveUserID()
        else {
            WableLogger.log("활성 세션의 아이디를 불러오지 못했습니다.", for: .error)
            
            return
        }
        
        activeID = id
    }
}
