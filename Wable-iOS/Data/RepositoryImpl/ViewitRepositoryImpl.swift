//
//  ViewitRepositoryImpl.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class ViewitRepositoryImpl {
    private let provider = APIProvider<ViewitTargetType>()
}

extension ViewitRepositoryImpl: ViewitRepository {
    func deleteViewit(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .deleteViewit(viewitID: viewitID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func deleteViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .deleteViewitLiked(viewitID: viewitID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func createViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createViewitLiked(viewitID: viewitID),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
    
    func fetchViewitList(cursor: Int) -> AnyPublisher<[Viewit], WableError> {
        return provider.request(
            .fetchViewitList(cursor: cursor),
            for: [DTO.Response.FetchViewits].self
        )
        .map(ViewitMapper.toDomain)
        .mapWableError()
    }
    
    func createViewitPost(
        thumbnailImageURLString: String,
        urlString: String,
        title: String,
        text: String
    ) -> AnyPublisher<Void, WableError> {
        return provider.request(
            .createViewitPost(
                request: DTO.Request.CreateViewitPost(
                    viewitImageURL: thumbnailImageURLString,
                    viewitURL: urlString,
                    viewitTitle: title,
                    viewitText: text
                )
            ),
            for: DTO.Response.Empty.self
        )
        .asVoid()
        .mapWableError()
    }
}
