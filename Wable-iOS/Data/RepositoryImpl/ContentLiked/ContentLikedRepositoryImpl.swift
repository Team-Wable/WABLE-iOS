//
//  ContentLikedRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/19/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class ContentLikedRepositoryImpl {
    private let provider = APIProvider<ContentLikedTargetType>()
}

extension ContentLikedRepositoryImpl: ContentLikedRepository {
    func createContentLiked(contentID: Int, triggerType: String) -> AnyPublisher<Void, Error> {
        return provider.request(
            .createContentLiked(
                contentID: contentID,
                request: DTO.Request.CreateContentLiked(alarmTriggerType: triggerType)
            ),
            for: DTO.Response.Empty.self
        )
        .asVoidWithError()
    }
    
    func deleteContentLiked(contentID: Int) -> AnyPublisher<Void, Error> {
        return provider.request(
            .deleteContentLiked(contentID: contentID),
            for: DTO.Response.Empty.self
        )
        .asVoidWithError()
    }
}
