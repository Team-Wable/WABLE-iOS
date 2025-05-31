//
//  CheckAppUpdateRequirementUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/29/25.
//

import Foundation

protocol CheckAppUpdateRequirementUseCase {
    func execute() async throws -> UpdateRequirement
}

final class CheckAppUpdateRequirementUseCaseImpl: CheckAppUpdateRequirementUseCase {
    @Injected private var appVersionRepository: AppVersionRepository
    @Injected private var updateAlertPolicyRepository: UpdateAlertPolicyRepository
    
    func execute() async throws -> UpdateRequirement {
        let appStoreVersion = try await appVersionRepository.fetchAppStoreVersion()
        let currentVersion = appVersionRepository.fetchCurrentVersion()
        let isAlreadyShown = updateAlertPolicyRepository.hasSeenOptionalAlert()
        
        let requirement: UpdateRequirement
        if appStoreVersion.major > currentVersion.major {
            requirement = .force
        } else if appStoreVersion.minor > currentVersion.minor {
            requirement = .frequent
        } else if appStoreVersion.patch > currentVersion.patch {
            requirement = .optional
        } else {
            requirement = .none
        }
        
        if requirement == .optional, isAlreadyShown {
            return .none
        }
        
        if requirement == .optional, !isAlreadyShown {
            updateAlertPolicyRepository.markOptionalAlertShown()
            return .optional
        }
        
        return requirement
    }
}
