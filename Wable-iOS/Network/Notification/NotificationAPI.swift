//
//  NotificationAPI.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/31/24.
//

import Foundation

import Moya

final class NotificationAPI: BaseAPI {
    static let shared =  NotificationAPI()
        private var notiProvider = MoyaProvider<NotificationRouter>(plugins: [MoyaLoggingPlugin()])
        private override init() {}
}

extension NotificationAPI {
    func getNotiInfo(cursor: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        notiProvider.request(.getNotiInfo(param: cursor)) { result in
            self.disposeNetwork(result,
                                dataModel: [InfoNotificationDTO].self,
                                completion: completion)
            
        }
    }
    
    func getNotiActivity(cursor: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        notiProvider.request(.getNotiActivity(param: cursor)) { result in
            self.disposeNetwork(result,
                                dataModel: [ActivityNotificationDTO].self,
                                completion: completion)
            
        }
    }
    
    func getFeedTopInfo(contentID: Int, completion: @escaping (NetworkResult<Any>) -> Void) {
        notiProvider.request(.getFeedTopInfo(param: contentID)) { result in
            self.disposeNetwork(result,
                                dataModel: HomeFeedDTO.self,
                                completion: completion)
            
        }
    }
}
