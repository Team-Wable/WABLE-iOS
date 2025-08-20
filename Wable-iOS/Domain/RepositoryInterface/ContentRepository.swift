//
//  ContentRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol ContentRepository {
    func createContent(title: String, text: String, image: Data?) -> AnyPublisher<Void, WableError>
    func deleteContent(contentID: Int) -> AnyPublisher<Void, WableError>
    func deleteContent(contentID: Int) async throws
    func fetchContentInfo(contentID: Int) -> AnyPublisher<ContentTemp, WableError>
    func fetchContentList(cursor: Int) -> AnyPublisher<[ContentTemp], WableError>
    func fetchUserContentList(memberID: Int, cursor: Int) -> AnyPublisher<[ContentTemp], WableError>
    func fetchUserContentList(memberID: Int, cursor: Int) async throws -> [ContentTemp]
}
