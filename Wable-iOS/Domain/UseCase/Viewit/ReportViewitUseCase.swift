//
//  ReportViewitUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import Combine
import Foundation

protocol ReportViewitUseCase {
    func report(viewit: Viewit, message: String) -> AnyPublisher<Viewit?, WableError>
    func ban(viewit: Viewit) -> AnyPublisher<Viewit?, WableError>
}

final class ReportViewitUseCaseImpl: ReportViewitUseCase {
    @Injected private var repository: ReportRepository
    
    func report(viewit: Viewit, message: String) -> AnyPublisher<Viewit?, WableError> {
        let text = message.isEmpty ? viewit.text : message
        return repository.createReport(nickname: viewit.userNickname, text: text)
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
