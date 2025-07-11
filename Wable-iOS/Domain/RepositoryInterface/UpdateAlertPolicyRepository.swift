//
//  UpdateAlertPolicyRepository.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/29/25.
//

import Foundation

protocol UpdateAlertPolicyRepository {
    func hasSeenOptionalAlert() -> Bool
    func markOptionalAlertShown()
}
