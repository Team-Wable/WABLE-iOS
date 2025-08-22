//
//  FetchUserCommentListUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol FetchUserCommentListUseCase {
    func execute(for userID: Int, last commentID: Int) async throws -> [CommentTemp]
}

final class FetchUserCommentListUseCaseImpl: FetchUserCommentListUseCase {
    @Injected private var repository: CommentRepository
    
    func execute(for userID: Int, last commentID: Int) async throws -> [CommentTemp] {
        if userID <= .zero {
            throw WableError.notFoundMember
        }
        
        return try await repository.fetchUserCommentList(memberID: userID, cursor: commentID)
    }
}
