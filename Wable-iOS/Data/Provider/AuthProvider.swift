//
//  AuthProvider.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/6/25.
//


import Combine
import Foundation

protocol AuthProvider {
    func authenticate() -> AnyPublisher<String?, WableError>
}
