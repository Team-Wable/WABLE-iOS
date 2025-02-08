//
//  JoinAPI.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/8/25.
//

import Foundation
import Combine

import CombineMoya
import Moya

final class JoinAPI: BaseAPI {
    static let shared = JoinAPI()
    
    private let joinProvider = MoyaProvider<JoinRouter>(plugins: [MoyaLoggingPlugin()])
    
    private override init() {}
}

extension JoinAPI {
    func getIsNicknameDuplicated(nickname: String) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        joinProvider.requestPublisher(.getIsDuplicatedNickname(nickname: nickname))
            .tryMap { [weak self] response -> EmptyDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func patchUserProfile(requestBody: UserInfoDTO) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        joinProvider.requestPublisher(.patchUserProfile(requestBody: requestBody))
            .tryMap { [weak self] response -> EmptyDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
