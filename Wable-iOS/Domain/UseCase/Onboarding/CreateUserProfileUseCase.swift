//
//  CreateUserProfileUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine
import UIKit

final class CreateUserProfileUseCase {
    let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
}

extension CreateUserProfileUseCase {
    func execute(profile: UserProfile, isPushAlarmAllowed: Bool, isAlarmAllowed: Bool, image: UIImage? = nil, defaultProfileType: String? = nil) -> AnyPublisher<Void, WableError> {
        return repository.updateUserProfile(
            profile: profile,
            isPushAlarmAllowed: isPushAlarmAllowed,
            isAlarmAllowed: isAlarmAllowed,
            image: image,
            defaultProfileType: defaultProfileType
        )
    }
}
