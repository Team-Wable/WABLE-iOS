//
//  LoginRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol LoginRepository {
    func updateTokenStatus() -> AnyPublisher<Token, WableError>
    func fetchUserAuth(platform: String, userName: String) -> AnyPublisher<Account, WableError>
}
