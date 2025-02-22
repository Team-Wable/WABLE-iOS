//
//  CommentRepository.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

protocol CommentRepository {
    func fetchUserCommentList(memberID: Int, cursor: Int) -> AnyPublisher<[UserComment], Error>
    func fetchContentCommentList(contentID: Int, cursor: Int) -> AnyPublisher<[ContentComment], Error>
    func deleteComment(commentID: Int) -> AnyPublisher<Void, Error>
    func createComment(contentID: Int, text: String, parentID: Int?, parentMemberID: Int?) -> AnyPublisher<Void, Error>
}
