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
    
    func migratedGetHomeFeed(cursor: Int) -> AnyPublisher<[HomeFeedDTO]?, WableNetworkError> {
        homeProvider.requestPublisher(.getContent(param: cursor))
            .tryMap { [weak self] response -> [HomeFeedDTO]? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func postFeedLike(contentID: Int) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        homeProvider.requestPublisher(.postFeedLike(contentID: contentID))
            .tryMap { [weak self] response -> EmptyDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func deleteFeedLike(contentID: Int) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        homeProvider.requestPublisher(.deleteFeedLike(contentID: contentID))
            .tryMap { [weak self] response -> EmptyDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func deleteFeed(contentID: Int) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        homeProvider.requestPublisher(.deleteFeed(contentID: contentID))
            .tryMap { [weak self] response -> EmptyDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func postReport(nickname: String, relateText: String) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        homeProvider.requestPublisher(.postReport(param: ReportRequestDTO(
            reportTargetNickname: nickname,
            relateText: relateText
        )))
        .tryMap { [weak self] response -> EmptyDTO? in
            return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
        }
        .mapError { $0 as? WableNetworkError ??
            .unknownError($0.localizedDescription) }
        .eraseToAnyPublisher()
    }
    
    func postBeGhost(triggerType: String, memberID: Int, triggerID: Int) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        let param = PostTransparencyRequestDTO(
            alarmTriggerType: triggerType,
            targetMemberId: memberID,
            alarmTriggerId: triggerID,
            ghostReason: ""
        )
        return homeProvider.requestPublisher(.postBeGhost(param: param))
            .tryMap { [weak self] response -> EmptyDTO? in
                return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
            }
            .mapError { $0 as? WableNetworkError ??
                .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
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
    
    func postBan(memberID: Int, triggerType: String, triggerID: Int) -> AnyPublisher<EmptyDTO?, WableNetworkError> {
        homeProvider.requestPublisher(.postBan(requestBody: BanRequestDTO(memberID: memberID,
                                                                          triggerType: triggerType,
                                                                          triggerID: triggerID)))
        .tryMap { [weak self] response -> EmptyDTO? in
            return try self?.parseResponse(statusCode: response.statusCode, data: response.data)
        }
        .mapError { $0 as? WableNetworkError ??
            .unknownError($0.localizedDescription)}
        .eraseToAnyPublisher()
    }
}
