//
//  HomeRouter.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/22/24.
//

import Foundation

import Moya

enum HomeRouter {
    case getContent(param: Int)
    case patchFCMToken(param: UserProfileRequestDTO)
    case postReply(param: Int, requestBody: WriteReplyRequestV3DTO)
    case postBan(requestBody: BanRequestDTO)
    case postFeedLike(contentID: Int)
    case deleteFeedLike(contentID: Int)
    case deleteFeed(contentID: Int)
    case postBeGhost(param: PostTransparencyRequestDTO)
    case postReport(param: ReportRequestDTO)
}

extension HomeRouter: BaseTargetType {
    var path: String {
        switch self {
        case .getContent:
            return StringLiterals.Endpoint.Home.getContent
        case .patchFCMToken:
            return StringLiterals.Endpoint.Home.patchUserProfile
        case .postReply(let contentID, _ ):
            return StringLiterals.Endpoint.Home.postReply(contentID: contentID)
        case .postBan:
            return StringLiterals.Endpoint.Home.postBan
        case .postFeedLike(let contentID):
            return StringLiterals.Endpoint.Home.postFeedLike(contentID: contentID)
        case .deleteFeedLike(let contentID):
            return StringLiterals.Endpoint.Home.deleteFeedLike(contentID: contentID)
        case .deleteFeed(let contentID):
            return StringLiterals.Endpoint.Home.deleteFeed(contentID: contentID)
        case .postBeGhost(let param):
            return StringLiterals.Endpoint.Home.postOpacityDown
        case .postReport:
            return StringLiterals.Endpoint.Home.postReport
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getContent:
            return .get
        case .patchFCMToken:
            return .patch
        case .postReply, .postBan, .postFeedLike, .postBeGhost, .postReport:
            return .post
        case .deleteFeed, .deleteFeedLike:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getContent(let cursor):
            return .requestParameters(parameters: ["cursor": cursor], encoding: URLEncoding.queryString)
            
        case .patchFCMToken(let data):
            var formData = [MultipartFormData]()
            
            // fcmToken 추가
            if let fcmTokenData = data.fcmToken?.data(using: .utf8) {
                let tokenPart = MultipartFormData(provider: .data(fcmTokenData), name: "fcmToken")
                formData.append(tokenPart)
            }
            
            // isPushAlarmAllowed 추가 (Bool을 문자열로 변환하여 전송)
            let pushAlarmData = String(describing: data.isPushAlarmAllowed).data(using: .utf8) ?? Data()
            let pushAlarmPart = MultipartFormData(provider: .data(pushAlarmData), name: "isPushAlarmAllowed")
            formData.append(pushAlarmPart)
            return .uploadMultipart(formData)
            
        case .postReply(_, let requestBody):
            return .requestJSONEncodable(requestBody)

        case .postBan(let requestBody):
            return .requestJSONEncodable(requestBody)
            
        case .postFeedLike:
            let requestBody = ContentLikeRequestDTO(alarmTriggerType: "contentLiked")
            return .requestJSONEncodable(requestBody)
            
        case .deleteFeedLike, .deleteFeed:
            return .requestPlain
            
        case .postBeGhost(let requestBody):
            return .requestJSONEncodable(requestBody)
            
        case .postReport(let requestBody):
            return .requestJSONEncodable(requestBody)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getContent, .postReply, .postBan, .postFeedLike, .deleteFeedLike, .postBeGhost, .deleteFeed, .postReport:
            return APIConstants.hasTokenHeader
        case .patchFCMToken:
            return APIConstants.multipartHeader
        }
    }
}
