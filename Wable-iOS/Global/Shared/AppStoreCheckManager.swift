//
//  AppStoreCheckManager.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/18/24.
//

import UIKit

final class AppStoreCheckManager {
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    static let appStoreOpenUrlString = "itms-apps://itunes.apple.com/app/apple-store/6670352454"
    
    func checkAppStoreVersion(completion: @escaping (Bool, String?) -> Void) {
        let bundleID = "com.wable.Wable-iOS"
        
        guard let url = URL(string: "https://itunes.apple.com/kr/lookup?bundleId=\(bundleID)") else {
            completion(false, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching App Store data: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let appStoreVersion = results.first?["version"] as? String else {
                print("Failed to parse App Store data.")
                completion(false, nil)
                return
            }
            
            // 현재 앱의 버전과 앱스토어 버전을 비교
            if let currentVersion = AppStoreCheckManager.appVersion {
                let isUpdateAvailable = self.isNewVersionAvailable(currentVersion: currentVersion, appStoreVersion: appStoreVersion)
                completion(isUpdateAvailable, appStoreVersion)
            } else {
                completion(false, nil)
            }
        }.resume()
    }
    
    // 버전 비교 메소드 (문자열 버전을 비교)
    private func isNewVersionAvailable(currentVersion: String, appStoreVersion: String) -> Bool {
        return appStoreVersion.compare(currentVersion, options: .numeric) == .orderedDescending
    }
    
    func openAppStore() {
        guard let url = URL(string: AppStoreCheckManager.appStoreOpenUrlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
