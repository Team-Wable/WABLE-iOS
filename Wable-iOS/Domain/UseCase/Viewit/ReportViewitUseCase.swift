//
//  ReportViewitUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import Foundation

protocol ReportViewitUseCase {
    func report(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
    func ban(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
}

final class ReportViewitUseCaseImpl: ReportViewitUseCase {
    @Injected private var repository: ReportRepository
    
    func report(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return repository.createReport(nickname: viewit.userNickname, text: viewit.text)
            .map { viewit }
            .eraseToAnyPublisher()
    }
    
    func ban(viewit: Viewit) -> AnyPublisher<Viewit?, WableError> {
        return repository.createBan(memberID: viewit.userID, triggerType: .viewit, triggerID: viewit.id)
            .map {
                var bannedViewit = viewit
                bannedViewit.status = .blind
                return bannedViewit
            }
            .eraseToAnyPublisher()
    }
}
