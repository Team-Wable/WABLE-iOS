//
//  FetchUserContentUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol FetchUserContentListUseCase {
    func execute(for userID: Int, last contentID: Int) async throws -> [ContentTemp]
}

final class FetchUserContentUseCaseImpl: FetchUserContentListUseCase {
    @Injected private var repository: ContentRepository
    
    func execute(for userID: Int, last contentID: Int) async throws -> [ContentTemp] {
        if userID < .zero {
            throw WableError.notFoundMember
        }
        
        return try await repository.fetchUserContentList(memberID: userID, cursor: contentID)
    }
}
