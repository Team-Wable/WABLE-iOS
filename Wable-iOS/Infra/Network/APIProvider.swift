//
//  APIProvider.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/14/25.
//

import Combine
import Foundation

import Alamofire
import CombineMoya
import Moya

final class APIProvider<Target: BaseTargetType>: MoyaProvider<Target> {
    private let jsonDecoder: JSONDecoder = .init()
    private let errorMonitor = OAuthErrorMonitor()
    private let interceptor: AuthenticationInterceptor<OAuthenticator>
    
    init() {
        self.interceptor = AuthenticationInterceptor(authenticator: OAuthenticator(errorMonitor: errorMonitor))
        
        let session: Session = .init(interceptor: interceptor)
        let plugin: [PluginType] = [MoyaLoggingPlugin()]
        
        super.init(session: session, plugins: plugin)
    }
    
    func request<D: Decodable>(
        _ target: Target,
        for type: D.Type
    ) -> AnyPublisher<D, NetworkError> {
        return self.requestPublisher(target)
            .map(\.data)
            .decode(type: BaseResponse<D>.self, decoder: jsonDecoder)
            .tryMap(validateResponse)
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
