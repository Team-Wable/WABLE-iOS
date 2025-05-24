//
//  ContentLikedRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol ContentLikedRepository {
    func createContentLiked(contentID: Int, triggerType: String) -> AnyPublisher<Void, WableError>
    func createContentLiked(contentID: Int, triggerType: String) async throws
    func deleteContentLiked(contentID: Int) -> AnyPublisher<Void, WableError>
    func deleteContentLiked(contentID: Int) async throws
}
