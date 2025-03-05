//
//  LoginRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol LoginRepository {
    func fetchAppleAuth() -> AnyPublisher<String, WableError>
    func fetchKakaoAuth() -> AnyPublisher<Void, WableError>
    func fetchUserAuth(platform: String, userName: String?) -> AnyPublisher<Account, WableError>
}
