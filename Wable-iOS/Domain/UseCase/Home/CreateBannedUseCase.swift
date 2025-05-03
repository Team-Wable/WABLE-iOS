//
//  CreateBannedUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 5/3/25.
//


import Combine
import Foundation

final class CreateBannedUseCase {
    private let repository: ReportRepository
    
    init(repository: ReportRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension CreateBannedUseCase {
    func execute(memberID: Int, triggerType: TriggerType.Ban, triggerID: Int) -> AnyPublisher<Void, WableError> {
        return repository.createBan(memberID: memberID, triggerType: triggerType, triggerID: triggerID)
    }
}
