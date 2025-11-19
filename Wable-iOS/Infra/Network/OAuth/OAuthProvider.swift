//
//  OAuthProvider.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 11/18/25.
//

import Combine
import Foundation

@preconcurrency import Moya

public final class OAuthProvider: Sendable {
    
    // MARK: - Property
    
    private let tokenRefreshProvider: MoyaProvider<LoginTargetType>
    private let userSessionStorage: UserDefaultsStorage
    private let tokenStorage: TokenStorage
    private let jsonDecoder: JSONDecoder
    private let cancelBag: CancelBag
    
    // MARK: - LifeCycle
    
    init(
        tokenRefreshProvider: MoyaProvider<LoginTargetType> = MoyaProvider<LoginTargetType>(
            plugins: [MoyaLoggingPlugin()]
        ),
        userSessionStorage: UserDefaultsStorage = UserDefaultsStorage(),
        tokenStorage: TokenStorage = TokenStorage(keyChainStorage: KeychainStorage()),
        jsonDecoder: JSONDecoder = JSONDecoder(),
        cancelBag: CancelBag = CancelBag()
    ) {
        self.tokenRefreshProvider = tokenRefreshProvider
        self.userSessionStorage = userSessionStorage
        self.tokenStorage = tokenStorage
        self.jsonDecoder = jsonDecoder
        self.cancelBag = cancelBag
    }
}

// MARK: - Internal Helper

extension OAuthProvider {
    func loadToken(for tokenType: TokenStorage.TokenType) throws -> String {
        return try tokenStorage.load(tokenType)
    }
    
    func saveToken(token: Token) throws {
        try tokenStorage.save(token.accessToken, for: .wableAccessToken)
        try tokenStorage.save(token.refreshToken, for: .wableRefreshToken)
    }

    func refreshToken() -> AnyPublisher<Token, WableError> {
        return tokenRefreshProvider.requestPublisher(.fetchTokenStatus)
            .map { $0.data }
            .decode(type: BaseResponse<DTO.Response.UpdateToken>.self, decoder: jsonDecoder)
            .tryMap { response -> DTO.Response.UpdateToken in
                guard response.success else { throw WableError.signinRequired }
                guard let data = response.data else { throw WableError.unknownError }
                return data
            }
            .map(LoginMapper.toDomain)
            .mapError { ($0 as? WableError) ?? .unknownError }
            .eraseToAnyPublisher()
    }
    
    func removeSession() {
        do {
            try tokenStorage.delete(.wableAccessToken)
            try tokenStorage.delete(.wableRefreshToken)
            try userSessionStorage.removeValue(for: Constants.activeUserID)
        } catch {
            WableLogger.log("세션 삭제 실패: \(error.localizedDescription)", for: .error)
        }
    }
}

// MARK: - Constant

private extension OAuthProvider {
    enum Constants {
        static let activeUserID = "activeID"
    }
}
