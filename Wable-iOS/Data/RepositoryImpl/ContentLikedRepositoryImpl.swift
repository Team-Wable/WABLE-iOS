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
    func createContentLiked(contentID: Int, triggerType: String) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createContentLiked(
                contentID: contentID,
                request: DTO.Request.CreateContentLiked(alarmTriggerType: triggerType)
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func createContentLiked(contentID: Int, triggerType: String) async throws {
        do {
            _ = try await provider.request(
                .createContentLiked(
                    contentID: contentID,
                    request: DTO.Request.CreateContentLiked(alarmTriggerType: triggerType)
                ),
                for: DTO.Response.Empty.self
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }
    
    func deleteContentLiked(contentID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .deleteContentLiked(contentID: contentID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func deleteContentLiked(contentID: Int) async throws {
        do {
            _ = try await provider.request(
                .deleteContentLiked(contentID: contentID),
                for: DTO.Response.Empty.self
            )
        } catch {
            throw ErrorMapper.map(error)
        }
    }
}
