//
//  ProfileRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol ProfileRepository {
    func fetchUserInfo() -> AnyPublisher<AccountInfo, Error>
    func fetchUserProfile(memberID: Int) -> AnyPublisher<UserProfile, Error>
    func updateUserProfile(profile: UserProfile, isPushAlarmAllowed: Bool) -> AnyPublisher<Void, Error>
}
