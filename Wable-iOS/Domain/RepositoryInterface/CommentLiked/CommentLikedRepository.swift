//
//  CommentLikedRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol CommentLikedRepository {
    func createCommentLiked(commentID: Int, triggerType: String, notificationText: String) -> AnyPublisher<Void, Error>
    func deleteCommentLiked(commentID: Int) -> AnyPublisher<Void, Error>
}
