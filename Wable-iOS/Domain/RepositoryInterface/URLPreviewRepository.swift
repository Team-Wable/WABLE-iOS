//
//  URLPreviewRepository.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/4/25.
//

import Combine
import Foundation

protocol URLPreviewRepository {
    func fetchPreview(url: URL) -> AnyPublisher<URLPreview, WableError>
}
