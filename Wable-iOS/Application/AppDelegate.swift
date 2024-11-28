//
//  AppDelegate.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/5/24.
//

import UIKit

import KakaoSDKCommon
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        KakaoSDK.initSDK(appKey: Config.nativeAppKey)
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("🔴 권한 요청 중 오류 발생: \(error.localizedDescription)")
            } else {
                if granted {
                    print("🟢 사용자가 알림 권한을 허용했습니다.")
                } else {
                    print("🔴 사용자가 알림 권한을 거부했습니다.")
                }
            }
            
            saveUserData(UserInfo(isSocialLogined: loadUserData()?.isSocialLogined ?? false,
                                  isFirstUser: loadUserData()?.isFirstUser ?? false,
                                  isJoinedApp: loadUserData()?.isJoinedApp ?? false,
                                  userNickname: loadUserData()?.userNickname ?? "",
                                  memberId: loadUserData()?.memberId ?? 0,
                                  userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                                  fcmToken: loadUserData()?.fcmToken ?? "",
                                  isPushAlarmAllowed: granted,
                                  isAdmin: loadUserData()?.isAdmin ?? false))
        }
    
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

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// 푸시 클릭 시
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let notiInfomation = response.notification.request.content.userInfo
        print("🍪🍪\(notiInfomation)")
        if let contentID = notiInfomation["relateContentId"] as? String,
           let aps = notiInfomation["aps"] as? [String: Any],
           let badge = aps["badge"] as? Int {
            let pushAlarmHelper = WablePushAlarmHelper(contentID: Int(contentID) ?? 0,
                                                        networkProvider: NetworkService())
            Task {
                do {
                    let result = try await pushAlarmHelper.patchFCMBadgeAPI(badge: badge - 1)
                    print("\(String(describing: result)) <- FCM 뱃지 API 통신 결과")
                } catch {
                    print("Error calling patchFCMBadgeAPI: \(error)")
                }
            }
            pushAlarmHelper.start()
        }
        print("🟢", #function)
    }
    
    /// 앱화면 보고있는중에 푸시올 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    /// FCMToken 업데이트시
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        saveUserData(UserInfo(isSocialLogined: loadUserData()?.isSocialLogined ?? false,
                              isFirstUser: loadUserData()?.isFirstUser ?? false,
                              isJoinedApp: loadUserData()?.isJoinedApp ?? false,
                              userNickname: loadUserData()?.userNickname ?? "",
                              memberId: loadUserData()?.memberId ?? 0,
                              userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                              fcmToken: fcmToken ?? "",
                              isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false,
                              isAdmin: loadUserData()?.isAdmin ?? false))
        print("🟢", #function, fcmToken ?? "")
    }
    
    /// 스위즐링 NO시, APNs등록, APNs토큰값가져옴
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        refreshFCMToken()
        print("🟢", #function)
    }
    
    /// error발생시
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🟢", error)
    }
    
    func refreshFCMToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                // 서버에 토큰을 갱신
                saveUserData(UserInfo(isSocialLogined: loadUserData()?.isSocialLogined ?? false,
                                      isFirstUser: loadUserData()?.isFirstUser ?? false,
                                      isJoinedApp: loadUserData()?.isJoinedApp ?? false,
                                      userNickname: loadUserData()?.userNickname ?? "",
                                      memberId: loadUserData()?.memberId ?? 0,
                                      userProfileImage: loadUserData()?.userProfileImage ?? StringLiterals.Network.baseImageURL,
                                      fcmToken: token,
                                      isPushAlarmAllowed: loadUserData()?.isPushAlarmAllowed ?? false,
                                      isAdmin: loadUserData()?.isAdmin ?? false))
            }
        }
    }
    
    func validateResult(_ result: NetworkResult<Any>) -> Any?{
        switch result{
        case .success(let data):
            return data
        case .requestErr(let message):
            print(message)
        case .pathErr:
            print("path 혹은 method 오류입니다.🤯")
        case .serverErr:
            print("서버 내 오류입니다.🎯")
        case .networkFail:
            print("네트워크가 불안정합니다.💡")
        case .decodedErr:
            print("디코딩 오류가 발생했습니다.🕹️")
        case .authorizationFail(_):
            print("인증 오류가 발생했습니다. 다시 로그인해주세요🔐")
        }
        return nil
    }
}

extension AppDelegate: MessagingDelegate {}
