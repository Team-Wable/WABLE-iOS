//
//  HomeAPI.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/22/24.
//

import Foundation

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
}
