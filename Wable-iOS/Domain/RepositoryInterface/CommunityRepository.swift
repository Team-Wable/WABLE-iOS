//
//  CommunityRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

protocol CommunityRepository {
    func updatePreRegister(communityName: LCKTeam) -> AnyPublisher<Void, WableError>
    func fetchCommunityList() -> AnyPublisher<[Community], WableError>
}
