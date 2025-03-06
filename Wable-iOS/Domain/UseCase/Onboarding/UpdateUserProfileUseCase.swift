//
//  UpdateUserProfileUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine

final class UpdateUserProfileUseCase {
    let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
}

extension UpdateUserProfileUseCase {
    func execute(profile: UserProfile, isPushAlarmAllowed: Bool) -> AnyPublisher<Void, WableError> {
        return repository.updateUserProfile(profile: profile, isPushAlarmAllowed: isPushAlarmAllowed)
    }
}
