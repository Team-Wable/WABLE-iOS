//
//  CreateViewitUseCase.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/7/25.
//

import Combine
import Foundation

protocol CreateViewitUseCase {
    func validate(_ urlString: String) -> Bool
    func execute(urlString: String, description: String) -> AnyPublisher<Void, WableError>
}

final class CreateViewitUseCaseImpl: CreateViewitUseCase {
    private static let urlDetector: NSDataDetector? = {
        do {
            return try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        } catch {
            WableLogger.log("NSDataDetector 초기화 오류: \(error.localizedDescription)", for: .error)
            return nil
        }
    }()
    
    @Injected private var urlPreviewRepository: URLPreviewRepository
    @Injected private var viewitRepository: ViewitRepository
    
    func validate(_ urlString: String) -> Bool {
        guard let detector = Self.urlDetector else {
            return false
        }
        
        let range = NSRange(location: 0, length: urlString.utf16.count)
        let matches = detector.matches(in: urlString, options: [], range: range)
        
        if let match = matches.first,
           match.range.length == urlString.utf16.count {
            return true
        }
        
        return false
    }
    
    func execute(urlString: String, description: String) -> AnyPublisher<Void, WableError> {
        let updatedURLString = checkURLScheme(urlString)
        
        guard let url = URL(string: updatedURLString) else {
            return .fail(.unknownError)
        }
        
        return urlPreviewRepository.fetchPreview(url: url)
            .flatMap { [weak self] preview -> AnyPublisher<Void, WableError> in
                guard let self else {
                    return .fail(.unknownError)
                }
                
                return viewitRepository.createViewit(
                    thumbnailImageURLString: preview.imageURLString,
                    urlString: preview.urlString,
                    title: preview.title,
                    text: description
                )
                .eraseToAnyPublisher()
            }
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
