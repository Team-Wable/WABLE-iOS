//
//  ContentRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol ContentRepository {
    func createContent(title: String, text: String, image: Data?) -> AnyPublisher<Void, Error>
    func deleteContent(contentID: Int) -> AnyPublisher<Void, Error>
    func fetchContentInfo(contentID: Int, title: String) -> AnyPublisher<ContentInfo, Error>
    func fetchContentList(cursor: Int) -> AnyPublisher<[Content], Error>
    func fetchUserContentList(memberID: Int, cursor: Int) -> AnyPublisher<[UserContent], Error>
}
