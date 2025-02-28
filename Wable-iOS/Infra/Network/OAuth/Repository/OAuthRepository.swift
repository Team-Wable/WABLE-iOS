//
//  OAuthRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/28/25.
//


import Combine
import Foundation

protocol OAuthRepository {
    func updateTokenStatus() -> AnyPublisher<Token, WableError>
}
