//
//  UserProfileUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine
import UIKit

final class UserProfileUseCase {
    let repository: ProfileRepository
    
    init(repository: ProfileRepository) {
        self.repository = repository
    }
}

extension UserProfileUseCase {
    func updateProfile(
        profile: UserProfile?,
        isPushAlarmAllowed: Bool? = nil,
        isAlarmAllowed: Bool? = nil,
        image: UIImage? = nil,
        defaultProfileType: String? = nil
    ) -> AnyPublisher<Void, WableError> {
        return repository.updateUserProfile(
            profile: profile,
            isPushAlarmAllowed: isPushAlarmAllowed,
            isAlarmAllowed: isAlarmAllowed,
            image: image,
            fcmToken: repository.fetchFCMToken(),
            defaultProfileType: defaultProfileType
        )
    }
    
    func fetchProfile(userID: Int) -> AnyPublisher<UserProfile, WableError> {
        return repository.fetchUserProfile(memberID: userID)
    }
    
    func updateProfileWithUserID(
        userID: Int,
        isPushAlarmAllowed: Bool? = nil,
        isAlarmAllowed: Bool? = nil,
        image: UIImage? = nil,
        defaultProfileType: String? = nil
    ) -> AnyPublisher<Void, WableError> {
        let fetchProfile = repository.fetchUserProfile(memberID: userID)
        let updateProfile = { [weak self] (profile: UserProfile) -> AnyPublisher<Void, WableError> in
            guard let self = self else { return Fail(error: WableError.unknownError).eraseToAnyPublisher() }
            
            return self.updateProfile(
                profile: profile,
                isPushAlarmAllowed: isPushAlarmAllowed,
                isAlarmAllowed: isAlarmAllowed,
                image: image,
                defaultProfileType: defaultProfileType
            )
        }
        
        return fetchProfile.flatMap(updateProfile).eraseToAnyPublisher()
    }
}
