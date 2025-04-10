//
//  CommunityUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/10/25.
//

import Combine
import Foundation

protocol CommunityUseCase {
    func isUserRegistered() -> AnyPublisher<CommunityRegistrationStatus, WableError>
    func fetchCommunityList() -> AnyPublisher<[Community], WableError>
    func register(for communityTeam: LCKTeam) -> AnyPublisher<Double, WableError>
}
