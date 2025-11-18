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
    
    // MARK: Property
    
    private let jsonDecoder: JSONDecoder
    
    // MARK: - LifeCycle
    
    init() {
        self.jsonDecoder = .init()

        let interceptor = OAuthRequestInterceptor(
            tokenStorage: TokenStorage(keyChainStorage: KeychainStorage()),
            removeUserSessionUseCase: RemoveUserSessionUseCaseImpl(),
            logoutHandler: { OAuthEventManager.shared.tokenExpiredSubject.send() },
            cancelBag: CancelBag()
        )

        super.init(session: Session(interceptor: interceptor), plugins: [MoyaLoggingPlugin()])
    }
}

// MARK: - Helper Methods

extension APIProvider {
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
    
    func request<D: Decodable>(
        _ target: Target,
        for type: D.Type
    ) async throws -> D {
        let response = try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let moyaResponse):
                    continuation.resume(returning: moyaResponse)
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.unknown(error))
                }
            }
        }
        
        do {
            let baseResponse = try jsonDecoder.decode(BaseResponse<D>.self, from: response.data)
            return try validateResponse(baseResponse)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodedError(decodingError)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}


// MARK: - Private Helper Methods

private extension APIProvider {
    func validateResponse<D>(_ baseResponse: BaseResponse<D>) throws -> D {
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
    
    func convertNetworkError(statusCode: Int, message: String) -> NetworkError {
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
