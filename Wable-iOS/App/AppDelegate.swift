//
//  AppDelegate.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//

import UIKit

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
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        injectDependency()
        fetchActiveID()
        configureFirebase(application: application)
        requestNotificationPermission()
        
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
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            guard let self = self,
                  let activeSession = userSessionRepository.fetchActiveUserSession() else { return }
            
            self.userSessionRepository.updateUserSession(
                UserSession(
                    id: activeSession.id,
                    nickname: activeSession.nickname,
                    profileURL: activeSession.profileURL,
                    isPushAlarmAllowed: granted,
                    isAdmin: activeSession.isAdmin,
                    isAutoLoginEnabled: activeSession.isAutoLoginEnabled,
                    notificationBadgeCount: activeSession.notificationBadgeCount
                )
            )
        }
    }
}
