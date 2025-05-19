//
//  CreateViewitUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/7/25.
//

import Combine
import Foundation

protocol CreateViewitUseCase {
    func validate(_ urlString: String) -> AnyPublisher<Bool, WableError>
    func execute(description: String) -> AnyPublisher<Bool, WableError>
}

final class CreateViewitUseCaseImpl: CreateViewitUseCase {
    
    @Injected private var urlPreviewRepository: URLPreviewRepository
    @Injected private var viewitRepository: ViewitRepository
    
    private var urlPreview: URLPreview?
    
    func validate(_ urlString: String) -> AnyPublisher<Bool, WableError> {
        urlPreview = nil
        
        let updatedURLString = checkURLScheme(urlString)
        
        guard let url = URL(string: updatedURLString) else {
            return .fail(.unknownError)
        }
        
        guard let scheme = url.scheme, !scheme.isEmpty,
              let host = url.host, !host.isEmpty
        else {
            return .fail(.validationException)
        }
        
        return urlPreviewRepository.fetchPreview(url: url)
            .handleEvents(receiveOutput: { [weak self] preview in
                self?.urlPreview = preview
            })
            .map { _ in true }
            .eraseToAnyPublisher()
    }
    
    func execute(description: String) -> AnyPublisher<Bool, WableError> {
        guard let urlPreview else {
            return .fail(.unknownError)
        }
        
        return viewitRepository.createViewit(
            thumbnailImageURLString: urlPreview.imageURLString,
            urlString: urlPreview.urlString,
            title: urlPreview.title,
            text: description,
            siteName: urlPreview.siteName
        )
        .map { _ in true }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Method

    private func checkURLScheme(_ urlText: String) -> String {
        let schemePattern = "^[a-zA-Z][a-zA-Z0-9+.-]*:"
        
        if let regex = try? NSRegularExpression(pattern: schemePattern, options: []),
           let _ = regex.firstMatch(in: urlText, options: [], range: NSRange(location: 0, length: urlText.utf16.count)) {
            return urlText
        }
        
        return "https://\(urlText)"
    }
}
