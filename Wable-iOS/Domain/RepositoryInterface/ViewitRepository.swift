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
    func createViewitLiked(viewitID: Int) -> AnyPublisher<Void, WableError>
    func fetchViewitList(cursor: Int) -> AnyPublisher<[Viewit], WableError>
    func createViewitPost(thumbnailURL: URL, videoURL: URL, title: String, text: String) -> AnyPublisher<Void, WableError>
}
