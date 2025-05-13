//
//  ViewitRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

protocol ViewitRepository {
    func deleteViewit(viewitID: Int) -> AnyPublisher<Void, WableError>
    func deleteViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError>
    func postViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError>
    func fetchViewitList(cursor: Int) -> AnyPublisher<[Viewit], WableError>
    func createViewit(
        thumbnailImageURLString: String,
        urlString: String,
        siteName: String,
        title: String,
        text: String
    ) -> AnyPublisher<Void, WableError>
}
