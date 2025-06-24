//
//  FetchGhostUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 5/2/25.
//


import Combine
import Foundation

final class FetchGhostUseCase {
    private let repository: GhostRepository
    
    init(repository: GhostRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension FetchGhostUseCase {
    func execute(type: PostType, targetID: Int, userID: Int, reason: String?) -> AnyPublisher<Void, WableError> {
        return repository.postGhostReduction(
            alarmTriggerType: type == .comment ? "commentGhost" : "contentGhost",
            alarmTriggerID: targetID,
            targetMemberID: userID,
            reason: reason ?? ""
        )
    }
}
