//
//  FetchUserContentUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import Foundation

protocol FetchUserContentListUseCase {
    func execute(for userID: Int, last contentID: Int) -> AnyPublisher<[UserContent], WableError>
}

final class FetchUserContentUseCaseImpl: FetchUserContentListUseCase {
    private let repository: ContentRepository
    
    init(repository: ContentRepository) {
        self.repository = repository
    }
    
    func execute(for userID: Int, last contentID: Int) -> AnyPublisher<[UserContent], WableError> {
        if userID < .zero {
            return .fail(.notFoundMember)
        }
        
        return repository.fetchUserContentList(memberID: userID, cursor: contentID)
    }
}
