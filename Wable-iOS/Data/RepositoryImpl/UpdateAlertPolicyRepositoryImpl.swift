//
//  UpdateAlertPolicyRepositoryImpl.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/29/25.
//

import Foundation

final class UpdateAlertPolicyRepositoryImpl: UpdateAlertPolicyRepository {
    
    private static let key = "OptionalUpdateAlertShown"
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func hasSeenOptionalAlert() -> Bool {
        return userDefaults.bool(forKey: Self.key)
    }
    
    func markOptionalAlertShown() {
        userDefaults.set(true, forKey: Self.key)
    }
}

// MARK: - Mock

struct MockUpdateAlertPolicyRepository: UpdateAlertPolicyRepository {
    func hasSeenOptionalAlert() -> Bool {
        return false
    }
    
    func markOptionalAlertShown() {}
}
