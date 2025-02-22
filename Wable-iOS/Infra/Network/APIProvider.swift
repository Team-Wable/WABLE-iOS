//
//  APIProvider.swift
//  Wable-iOS
//
//  Created by 김진웅 on 2/14/25.
//

import Combine
import Foundation

import CombineMoya
import Moya

final class APIProvider<Target: BaseTargetType>: MoyaProvider<Target> {
    private let jsonDecoder: JSONDecoder = .init()
    
    init(interceptor: RequestInterceptor? = nil) {
        let session: Session = .init(interceptor: interceptor)
        let plugin: [PluginType] = [MoyaLoggingPlugin()]
        super.init(session: session, plugins: plugin)
    }
    
    func request<D: Decodable>(
        _ target: Target,
        for type: D.Type
    ) -> AnyPublisher<D, WableNetworkError> {
        return self.requestPublisher(target)
            .map(\.data)
            .decode(type: BaseResponse<D>.self, decoder: jsonDecoder)
            .tryMap(validateResponse)
            .mapError { $0 as? WableNetworkError ?? .unknown($0) }
            .eraseToAnyPublisher()
    }
    
    private func validateResponse<D>(_ baseResponse: BaseResponse<D>) throws -> D {
        guard baseResponse.success else {
            throw mapError(statusCode: baseResponse.status, message: baseResponse.message)
        }
        
        if D.self == DTO.Response.Empty.self,
           let emptyInstance = DTO.Response.Empty() as? D {
            return emptyInstance
        }
        
        guard let data = baseResponse.data else {
            throw WableNetworkError.missingData
        }
        
        return data
    }
    
    private func mapError(statusCode: Int, message: String) -> WableNetworkError {
        switch statusCode {
        case 400:
            return .badRequest(message: message)
        case 401:
            return .unauthorized(message: message)
        case 404:
            return .notFound(message: message)
        case 500:
            return .internalServerError
        default:
            return .unknown(NSError(domain: "UnknownError", code: statusCode))
        }
    }
}
