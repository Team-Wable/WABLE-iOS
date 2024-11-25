//
//  InfoAPI.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/28/24.
//

import Foundation
import Combine

import CombineMoya
import Moya

final class InfoAPI: BaseAPI {
    static let shared =  InfoAPI()
    
    private let infoProvider = MoyaProvider<InfoRouter>(plugins: [MoyaLoggingPlugin()])
    
    private override init() {}
}

extension InfoAPI {
    func getMatchInfo() -> AnyPublisher<[TodayMatchesDTO]?, WableNetworkError> {
        infoProvider.requestPublisher(.getMatchInfo)
            .tryMap { [weak self] response -> [TodayMatchesDTO]? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func getGameType() -> AnyPublisher<LCKGameTypeDTO?, WableNetworkError> {
        infoProvider.requestPublisher(.getGameType)
            .tryMap { [weak self] response -> LCKGameTypeDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func getTeamRank() -> AnyPublisher<[LCKTeamRankDTO]?, WableNetworkError> {
        infoProvider.requestPublisher(.getTeamRank)
            .tryMap { [weak self] response -> [LCKTeamRankDTO]? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func getNews(cursor: Int) -> AnyPublisher<[NewsDTO]?, WableNetworkError> {
        infoProvider.requestPublisher(.getNews(param: cursor))
            .tryMap { [weak self] response -> [NewsDTO]? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
