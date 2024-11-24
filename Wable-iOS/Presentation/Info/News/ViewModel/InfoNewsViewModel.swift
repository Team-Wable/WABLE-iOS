//
//  InfoNewsViewModel.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import Foundation
import Combine

final class InfoNewsViewModel {
    private var cursor: Int = -1
    
    private let service: InfoAPI
    
    init(service: InfoAPI = InfoAPI.shared) {
        self.service = service
    }
}

extension InfoNewsViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let news: AnyPublisher<[NewsDTO], Never>
    }
    
    func transform(from input: Input, cancelBag: CancelBag) -> Output {
        let news = input.viewWillAppear
            .flatMap { [weak self] _ -> AnyPublisher<[NewsDTO], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return service.getNews(cursor: -1)
                    .compactMap { $0 }
                    .mapWableNetworkError()
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .removeDuplicates()
            .map { NewsTimeFormatter(news: $0).formattedNews() }
            .eraseToAnyPublisher()
        
        return Output(
            news: news
        )
    }
}
