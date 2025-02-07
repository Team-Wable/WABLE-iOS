//
//  LoginAPI.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/6/25.
//

import Foundation
import Combine

import CombineMoya
import Moya

final class LoginAPI: BaseAPI {
    static let shared = LoginAPI()
    
    private let loginProvider = MoyaProvider<LoginRouter>(plugins: [MoyaLoggingPlugin()])
    
    private override init() {}
}

extension LoginAPI {
    func postSocialLogin(requestBody: SocialLoginRequestDTO, accessToken: String) -> AnyPublisher<SocialLoginResponseDTO?, WableNetworkError> {
        loginProvider.requestPublisher(.postSocialLogin(requestBody: requestBody, accessToken: accessToken))
            .tryMap { [weak self] response -> SocialLoginResponseDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
