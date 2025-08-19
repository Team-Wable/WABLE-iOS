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
    func createContent(title: String, text: String, image: Data?) -> AnyPublisher<Void, WableError> {
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
        .asVoid()
        .mapWableError()
    }
    
    func deleteContent(contentID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .deleteContent(contentID: contentID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func deleteContent(contentID: Int) async throws {
        do {
            _ = try await provider.request(
                .deleteContent(contentID: contentID),
                for: DTO.Response.Empty.self
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }
    
    func fetchContentInfo(contentID: Int) -> AnyPublisher<ContentTemp, WableError> {
        provider.request(
            .fetchContentInfo(contentID: contentID),
            for: DTO.Response.FetchContent.self
        )
        .map { ContentMapper.toDomain($0, contentID) }
        .mapWableError()
    }
    
    func fetchContentList(cursor: Int) -> AnyPublisher<[ContentTemp], WableError> {
        provider.request(
            .fetchContentList(cursor: cursor),
            for: [DTO.Response.FetchContents].self
        )
        .map(ContentMapper.toDomain)
        .mapWableError()
    }
    
    func fetchUserContentList(memberID: Int, cursor: Int) -> AnyPublisher<[ContentTemp], WableError> {
        provider.request(
            .fetchUserContentList(memberID: memberID, cursor: cursor),
            for: [DTO.Response.FetchUserContents].self
        )
        .map(ContentMapper.toDomain)
        .mapWableError()
    }
    
    func fetchUserContentList(memberID: Int, cursor: Int) async throws -> [ContentTemp] {
        do {
            let response = try await provider.request(
                .fetchUserContentList(memberID: memberID, cursor: cursor),
                for: [DTO.Response.FetchUserContents].self
            )
            return ContentMapper.toDomain(response)
        } catch {
            throw ErrorMapper.map(error)
        }
    }
}
