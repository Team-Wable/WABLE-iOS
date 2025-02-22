//
//  ContentRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/19/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class ContentRepositoryImpl {
    private let provider = APIProvider<ContentTargetType>()
}

extension ContentRepositoryImpl: ContentRepository {
    func createContent(title: String, text: String, image: Data?) -> AnyPublisher<Void, any Error> {
        return provider.request(
            .createContent(
                request: DTO.Request.CreateContent(
                    text: DTO.Request.Content(
                        contentTitle: title,
                        contentText: text
                    ),
                    image: image
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoidWithError()
    }
    
    func deleteContent(contentID: Int) -> AnyPublisher<Void, any Error> {
        return provider.request(
            .deleteContent(contentID: contentID),
            for: DTO.Response.Empty.self
        )
        .asVoidWithError()
    }
    
    func fetchContentInfo(contentID: Int, title: String) -> AnyPublisher<ContentInfo, any Error> {
        provider.request(
            .fetchContentInfo(contentID: contentID),
            for: DTO.Response.FetchContent.self
        )
        .map { contentInfo in
            ContentMapper.contentInfoMapper(contentInfo, title)
        }
        .normalizeError()
    }
    
    func fetchContentList(cursor: Int) -> AnyPublisher<[Content], any Error> {
        provider.request(
            .fetchContentList(cursor: cursor),
            for: [DTO.Response.FetchContents].self
        )
        .map { contents in
            ContentMapper.contentListMapper(contents)
        }
        .normalizeError()
    }
    
    func fetchUserContentList(memberID: Int, cursor: Int) -> AnyPublisher<[UserContent], any Error> {
        provider.request(
            .fetchUserContentList(memberID: memberID, cursor: cursor),
            for: [DTO.Response.FetchUserContents].self
        )
        .map { contents in
            ContentMapper.userContentListMapper(contents)
        }
        .normalizeError()
    }
}
