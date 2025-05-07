//
//  CreateReportUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 5/3/25.
//


import Combine
import Foundation

final class CreateReportUseCase {
    private let repository: ReportRepository
    
    init(repository: ReportRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension CreateReportUseCase {
    func execute(nickname: String, text: String) -> AnyPublisher<Void, WableError> {
        return repository.createReport(nickname: nickname, text: text)
    }
}
