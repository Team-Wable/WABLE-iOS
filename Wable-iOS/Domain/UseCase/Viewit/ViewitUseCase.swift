//
//  ViewitUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/9/25.
//

import Combine
import Foundation

protocol ViewitUseCase {
    func fetchViewitList(last viewitID: Int) -> AnyPublisher<[Viewit], WableError>
    func delete(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
}

final class ViewitUseCaseImpl: ViewitUseCase {
    @Injected private var viewitRepository: ViewitRepository
    
    func fetchViewitList(last viewitID: Int) -> AnyPublisher<[Viewit], WableError> {
        return viewitRepository.fetchViewitList(cursor: viewitID)
    }
    
    func delete(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return viewitRepository.deleteViewit(viewitID: viewit.id)
            .map { viewit }
            .eraseToAnyPublisher()
    }
}
