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
        
        let hasSeenOptionalAlert = updateAlertPolicyRepository.hasSeenOptionalAlert(for: appStoreVersion.description)
        if requirement == .optional, hasSeenOptionalAlert {
            return .none
        }
        
        if requirement == .optional, !hasSeenOptionalAlert {
            updateAlertPolicyRepository.markOptionalAlertShown(for: appStoreVersion.description)
            return .optional
        }
        
        return requirement
    }
}
