//
//  ProfileRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation
import UIKit

protocol ProfileRepository {
    func fetchUserInfo() -> AnyPublisher<AccountInfo, WableError>
    func fetchUserProfile(memberID: Int) -> AnyPublisher<UserProfile, WableError>
    func updateUserProfile(
        profile: UserProfile,
        isPushAlarmAllowed: Bool,
        isAlarmAllowed: Bool,
        image: UIImage?,
        defaultProfileType: String?
    ) -> AnyPublisher<Void, WableError>
}
