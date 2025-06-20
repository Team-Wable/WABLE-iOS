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
    func fetchAccountInfo() async throws -> AccountInfo
    func fetchUserProfile(memberID: Int) -> AnyPublisher<UserProfile, WableError>
    func fetchUserProfile(memberID: Int) async throws -> UserProfile
    func fetchFCMToken() -> String?
    func updateFCMToken(token: String)
    func updateUserProfile(nickname: String, fcmToken: String?) -> AnyPublisher<Void, WableError>
    func updateUserProfile(
        profile: UserProfile?,
        isPushAlarmAllowed: Bool?,
        isAlarmAllowed: Bool?,
        image: UIImage?,
        fcmToken: String?,
        defaultProfileType: String?
    ) -> AnyPublisher<Void, WableError>
}
