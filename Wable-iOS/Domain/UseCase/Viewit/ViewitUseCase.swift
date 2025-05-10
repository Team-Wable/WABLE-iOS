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
    func like(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
    func unlinke(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
    func delete(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
    func report(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
    func ban(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
}

final class ViewitUseCaseImpl: ViewitUseCase {
    
    // TODO: 기능 구현 후, 객체 교체
    
    @Injected(config: .debug) private var viewitRepository: ViewitRepository
    @Injected(config: .debug) private var reportRepository: ReportRepository
    
    func fetchViewitList(last viewitID: Int) -> AnyPublisher<[Viewit], WableError> {
        return viewitRepository.fetchViewitList(cursor: viewitID)
    }
    
    func like(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return viewitRepository.postViewitLiked(viewitID: viewit.id)
            .map {
                var likedViewit = viewit
                likedViewit.like.like()
                return likedViewit
            }
            .eraseToAnyPublisher()
    }
    
    func unlinke(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return viewitRepository.deleteViewitLiked(viewitID: viewit.id)
            .map {
                var unlikedViewit = viewit
                unlikedViewit.like.unlike()
                return unlikedViewit
            }
            .eraseToAnyPublisher()
    }
    
    func delete(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return viewitRepository.deleteViewit(viewitID: viewit.id)
            .map { viewit }
            .eraseToAnyPublisher()
    }
    
    func report(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return reportRepository.createReport(nickname: viewit.userNickname, text: viewit.text)
            .map { viewit }
            .eraseToAnyPublisher()
    }
    
    func ban(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return reportRepository.createBan(memberID: viewit.userID, triggerType: .viewit, triggerID: viewit.id)
            .map {
                var bannedViewit = viewit
                bannedViewit.status = .blind
                return bannedViewit
            }
            .eraseToAnyPublisher()
    }
}
