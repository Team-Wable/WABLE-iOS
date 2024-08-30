//
//  InfoAPI.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/28/24.
//

import Foundation

import Moya

final class InfoAPI: BaseAPI {
    static let shared =  InfoAPI()
        private var infoProvider = MoyaProvider<InfoRouter>(plugins: [MoyaLoggingPlugin()])
        private override init() {}
}

extension InfoAPI {
    func getMatchInfo(completion: @escaping (NetworkResult<Any>) -> Void) {
        infoProvider.request(.getMatchInfo) { result in
            self.disposeNetwork(result,
                                dataModel: [TodayMatchesDTO].self,
                                completion: completion)
            
        }
    }
}
