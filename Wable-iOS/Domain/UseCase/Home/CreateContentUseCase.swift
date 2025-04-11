//
//  CreateContentUseCase.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/31/25.
//


import Combine
import Foundation

final class CreateContentUseCase {
    private let repository: ContentRepository
    
    init(repository: ContentRepository) {
        self.repository = repository
    }
}

// MARK: - Extension

extension CreateContentUseCase {
    func execute(title: String, text: String, image: Data?) -> AnyPublisher<Void, WableError> {
        return repository.createContent(title: title, text: text, image: image)
    }
}
