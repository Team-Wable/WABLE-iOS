//
//  LikeViewitUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import Foundation

protocol LikeViewitUseCase {
    func like(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
    func unlike(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
}

final class LikeViewitUseCaseImpl: LikeViewitUseCase {
    @Injected private var repository: ViewitRepository
    
    func like(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return repository.postViewitLiked(viewitID: viewit.id)
            .map {
                var likedViewit = viewit
                likedViewit.like()
                return likedViewit
            }
            .eraseToAnyPublisher()
    }
    
    func unlike(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return repository.deleteViewitLiked(viewitID: viewit.id)
            .map {
                var unlikedViewit = viewit
                unlikedViewit.unlike()
                return unlikedViewit
            }
            .eraseToAnyPublisher()
    }
}
