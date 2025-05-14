//
//  CreateUserProfileUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine
import UIKit

final class userProfileUseCase {
    let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
}

extension userProfileUseCase {
    func execute(profile: UserProfile? = nil, isPushAlarmAllowed: Bool? = nil, isAlarmAllowed: Bool? = nil, image: UIImage? = nil, defaultProfileType: String? = nil) -> AnyPublisher<Void, WableError> {
        return repository.updateUserProfile(
            profile: profile,
            isPushAlarmAllowed: isPushAlarmAllowed,
            isAlarmAllowed: isAlarmAllowed,
            image: image,
            fcmToken: repository.fetchFCMToken(),
            defaultProfileType: defaultProfileType
        )
    }
    
    func execute(userID: Int) -> AnyPublisher<UserProfile, WableError> {
        return repository.fetchUserProfile(memberID: userID)
    }
}
