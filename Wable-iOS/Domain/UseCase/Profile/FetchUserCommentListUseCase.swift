//
//  FetchUserCommentListUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol FetchUserCommentListUseCase {
    func execute(for userID: Int, last commentID: Int) -> AnyPublisher<[UserComment], WableError>
}

final class FetchUserCommentListUseCaseImpl: FetchUserCommentListUseCase {
    private let repository: CommentRepository
    
    init(repository: CommentRepository) {
        self.repository = repository
    }
    
    func execute(for userID: Int, last commentID: Int) -> AnyPublisher<[UserComment], WableError> {
        guard userID > .zero else {
            return .fail(.notFoundMember)
        }

        return repository.fetchUserCommentList(memberID: userID, cursor: commentID)
    }
}
