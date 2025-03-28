//
//  APIProvider.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/14/25.
//

import Combine
import UIKit

import Alamofire
import CombineMoya
import Moya

final class APIProvider<Target: BaseTargetType>: MoyaProvider<Target> {
    private let jsonDecoder: JSONDecoder = .init()
    private let interceptor: AuthenticationInterceptor<OAuthenticator>
    
    init() {
        
        let authenticator = OAuthenticator(
            tokenStorage: TokenStorage(keyChainStorage: KeychainStorage())
        )
        
        let credential = OAuthCredential(
            accessToken: "",
            refreshToken: "",
            requiresRefresh: false
        )
        
        self.interceptor = AuthenticationInterceptor(
            authenticator: authenticator,
            credential: credential
        )
        
        let logoutHandler = {
            let userSessionRepository = UserSessionRepositoryImpl(userDefaults: UserDefaultsStorage(
                userDefaults: UserDefaults.standard,
                jsonEncoder: JSONEncoder(),
                jsonDecoder: JSONDecoder()
            ))
            
            userSessionRepository.updateActiveUserID(nil)
            
            OAuthEventManager.shared.tokenExpiredSubject.send()
        }
        
        let session = Session(interceptor: interceptor)
        let plugin: [PluginType] = [MoyaLoggingPlugin(logoutHandler: logoutHandler)]
        
        super.init(session: session, plugins: plugin)
    }
    
    /// Sends an API request to the specified target and publishes a decoded response.
    ///
    /// This method initiates a network request using the provided target. It extracts the response data, decodes it into a `BaseResponse` wrapping the expected type, and validates the response. Any decoding or validation errors are mapped to a corresponding `NetworkError`.
    ///
    /// - Parameters:
    ///   - target: The API endpoint configuration for the request.
    ///   - type: The expected type for decoding the response data.
    /// - Returns: A publisher that emits the decoded response data or a `NetworkError`.
    func request<D: Decodable>(
        _ target: Target,
        for type: D.Type
    ) -> AnyPublisher<D, NetworkError> {
        return self.requestPublisher(target)
            .map { $0.data }
            .decode(type: BaseResponse<D>.self, decoder: jsonDecoder)
            .tryMap { response in
                return try self.validateResponse(response)
            }
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return .decodedError(decodingError)
                }
                return error as? NetworkError ?? .unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
    private func validateResponse<D>(_ baseResponse: BaseResponse<D>) throws -> D {
        guard baseResponse.success else {
            throw convertNetworkError(statusCode: baseResponse.status, message: baseResponse.message)
        }
        
        if D.self == DTO.Response.Empty.self,
           let emptyInstance = DTO.Response.Empty() as? D {
            return emptyInstance
        }
        
        guard let data = baseResponse.data else {
            throw NetworkError.missingData
        }
        
        return data
    }
    
    private func convertNetworkError(statusCode: Int, message: String) -> NetworkError {
        switch statusCode {
        case 400..<500:
            return .statusError(code: statusCode, message: message)
        case 500...:
            return .internalServerError
        default:
            return .unknown(NSError(domain: "UnknownError", code: statusCode))
        }
    }
}
