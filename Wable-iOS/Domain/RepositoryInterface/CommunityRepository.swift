//
//  CommunityRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

protocol CommunityRepository {
    func updateRegister(communityName: String) -> AnyPublisher<Double, WableError>
    func fetchCommunityList() -> AnyPublisher<[Community], WableError>
    func isUserRegistered() -> AnyPublisher<CommunityRegistrationStatus, WableError>
}
