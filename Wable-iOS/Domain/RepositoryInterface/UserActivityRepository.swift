//
//  UserActivityRepository.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/24/25.
//

import Foundation
import Combine

protocol UserActivityRepository {
    func fetchUserActivity(for userID: UInt) -> AnyPublisher<UserActivity, WableError>
    func updateUserActivity(for userID: UInt, _ activity: UserActivity) -> AnyPublisher<Void, WableError>
}
