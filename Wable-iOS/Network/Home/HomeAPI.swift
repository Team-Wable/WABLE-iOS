//
//  HomeAPI.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/22/24.
//

import Foundation
import Combine

import CombineMoya
import Moya

final class HomeAPI: BaseAPI {
    static let shared =  HomeAPI()
    private var homeProvider = MoyaProvider<HomeRouter>(plugins: [MoyaLoggingPlugin()])
    private override init() {}
}

extension HomeAPI {
    func getHomeContent(cursor: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        homeProvider.request(.getContent(param: cursor)) { result in
            self.disposeNetwork(result,
                                dataModel: [HomeFeedDTO].self,
                                completion: completion)
            
        }
    }
    
    func postReply(contentID: Int, requestBody: WriteReplyRequestV3DTO) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        homeProvider.requestPublisher(.postReply(param: contentID, requestBody: requestBody))
            .tryMap { [weak self] response -> EmptyDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ??
                .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
