//
//  UpdateAlertPolicyRepositoryImpl.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/29/25.
//

import Foundation

final class UpdateAlertPolicyRepositoryImpl: UpdateAlertPolicyRepository {
    
    private static let key = "lastSeenOptionalUpdateVersion"
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func hasSeenOptionalAlert(for version: String) -> Bool {
        return userDefaults.string(forKey: Self.key) == version
    }
    
    func markOptionalAlertShown(for version: String) {
        userDefaults.set(version, forKey: Self.key)
    }
}

// MARK: - Mock

struct MockUpdateAlertPolicyRepository: UpdateAlertPolicyRepository {
    func hasSeenOptionalAlert(for version: String) -> Bool {
        return false
    }
    
    func markOptionalAlertShown(for version: String) {}
}
