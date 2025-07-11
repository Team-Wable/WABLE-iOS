//
//  CommentLikedRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol CommentLikedRepository {
    func createCommentLiked(commentID: Int, triggerType: String, notificationText: String) -> AnyPublisher<Void, WableError>
    func createCommentLiked(commentID: Int, triggerType: String, notificationText: String) async throws
    func deleteCommentLiked(commentID: Int) -> AnyPublisher<Void, WableError>
    func deleteCommentLiked(commentID: Int) async throws
}
