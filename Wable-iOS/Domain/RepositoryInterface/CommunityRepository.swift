//
//  CommunityRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

protocol CommunityRepository {
    func updateRegistration(communityName: String) -> AnyPublisher<Double, WableError>
    func fetchCommunityList() -> AnyPublisher<[Community], WableError>
    func checkUserRegistration() -> AnyPublisher<CommunityRegistration, WableError>
}
